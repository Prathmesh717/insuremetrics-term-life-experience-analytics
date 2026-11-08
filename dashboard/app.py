"""Interactive management dashboard for mortality and lapse study results."""

from pathlib import Path

import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st


ROOT = Path(__file__).parents[1]
OUTPUTS = ROOT / "data" / "outputs"
ACTION_COLORS = {
    "STRENGTHEN_ASSUMPTION": "#c2410c",
    "STRENGTHEN_LAPSE_ASSUMPTION": "#c2410c",
    "WEAKEN_ASSUMPTION": "#2563eb",
    "WEAKEN_LAPSE_ASSUMPTION": "#2563eb",
    "MONITOR": "#d97706",
    "MAINTAIN": "#15803d",
    "LOW_CREDIBILITY": "#64748b",
}


@st.cache_data
def load_results() -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    mortality = pd.read_csv(OUTPUTS / "mortality_results.csv")
    lapse = pd.read_csv(OUTPUTS / "lapse_results.csv")
    validation = pd.read_csv(OUTPUTS / "validation_results.csv")
    return mortality, lapse, validation


def pct(value: float) -> str:
    return "—" if pd.isna(value) else f"{100 * value:,.1f}%"


def mortality_trend_chart(data: pd.DataFrame) -> go.Figure:
    trend = data[data["analysis_name"] == "calendar_year"].copy()
    trend = trend.sort_values("dimension_1_value")
    trend["year"] = trend["dimension_1_value"].astype(str)
    fig = go.Figure()
    fig.add_trace(
        go.Scatter(
            x=trend["year"],
            y=100 * trend["count_ae_upper_95"],
            line={"width": 0},
            showlegend=False,
            hoverinfo="skip",
        )
    )
    fig.add_trace(
        go.Scatter(
            x=trend["year"],
            y=100 * trend["count_ae_lower_95"],
            fill="tonexty",
            fillcolor="rgba(37,99,235,0.12)",
            line={"width": 0},
            name="95% interval",
            hoverinfo="skip",
        )
    )
    fig.add_trace(
        go.Scatter(
            x=trend["year"],
            y=100 * trend["count_ae_ratio"],
            mode="lines+markers",
            line={"color": "#1d4ed8", "width": 3},
            name="Count A/E",
        )
    )
    fig.add_hline(y=100, line_dash="dash", line_color="#475569")
    fig.update_layout(
        height=390,
        yaxis_title="A/E (%)",
        xaxis_title=None,
        margin={"l": 10, "r": 10, "t": 20, "b": 10},
        legend={"orientation": "h", "y": 1.12},
    )
    return fig


st.set_page_config(
    page_title="InsureMetrics Term Life Insurance Experience & Portfolio Analytics Engine",
    page_icon="📊",
    layout="wide",
)
st.markdown(
    """
    <style>
    .block-container {padding-top: 1.7rem; padding-bottom: 3rem;}
    [data-testid="stMetric"] {background:#f8fafc; color:#0f172a; border:1px solid #e2e8f0;
        border-radius:10px; padding:14px 16px;}
    .study-note {background:#eff6ff; border-left:4px solid #2563eb;
        padding:14px 18px; border-radius:4px; margin:8px 0 18px;}
    </style>
    """,
    unsafe_allow_html=True,
)

required = [
    OUTPUTS / "mortality_results.csv",
    OUTPUTS / "lapse_results.csv",
    OUTPUTS / "validation_results.csv",
]
if not all(path.exists() for path in required):
    st.error("Dashboard exports are missing. Run `./scripts/run_study.sh` first.")
    st.stop()

mortality, lapse, validation = load_results()
portfolio = mortality[mortality["analysis_name"] == "portfolio"].iloc[0]
lapse_portfolio = lapse[lapse["analysis_name"] == "portfolio"].iloc[0]

st.title("InsureMetrics")
st.subheader("Term-Life Insurance Experience & Portfolio Analytics Engine")
st.caption(
    "Actuarial Intelligence | Mortality Analytics | Lapse Analytics | "
    "Portfolio Insights · Observation period 2021–2025 · Synthetic data"
)

executive_tab, mortality_tab, segment_tab, lapse_tab, controls_tab = st.tabs(
    ["Executive summary", "Mortality trend", "Segment investigation", "Lapse", "Controls"]
)

with executive_tab:
    cols = st.columns(5)
    cols[0].metric("Life-years", f"{portfolio['exposure']:,.0f}")
    cols[1].metric("Actual / expected deaths", f"{portfolio['actual_deaths']:,.0f} / {portfolio['expected_deaths']:,.1f}")
    cols[2].metric("Count A/E", pct(portfolio["count_ae_ratio"]))
    cols[3].metric("Amount A/E", pct(portfolio["amount_ae_ratio"]))
    cols[4].metric("Credibility-weighted A/E", pct(portfolio["credible_count_ae"]))

    st.markdown(
        f"""
        <div class="study-note"><b>Portfolio recommendation: {portfolio['recommended_action']}</b><br>
        Observed mortality is {pct(portfolio['count_ae_ratio'])} of expected, with a 95% interval of
        {pct(portfolio['count_ae_lower_95'])}–{pct(portfolio['count_ae_upper_95'])} and
        {pct(portfolio['credibility'])} limited-fluctuation credibility. The result supports monitoring,
        not an immediate portfolio-wide basis change.</div>
        """,
        unsafe_allow_html=True,
    )
    left, right = st.columns([1.35, 1])
    with left:
        st.subheader("Calendar-year mortality")
        st.plotly_chart(mortality_trend_chart(mortality), width="stretch", key="executive_trend")
    with right:
        st.subheader("Largest excess-death contributors")
        material = mortality[
            (~mortality["analysis_name"].isin(["portfolio", "calendar_year"]))
            & (mortality["exposure"] >= 250)
        ].nlargest(8, "excess_deaths")
        material = material.assign(
            Segment=material["dimension_1_value"].astype(str)
            + material["dimension_2_value"].fillna("").map(lambda x: f" / {x}" if x else ""),
            **{"Count A/E": 100 * material["count_ae_ratio"]},
        )
        st.dataframe(
            material[["analysis_name", "Segment", "actual_deaths", "Count A/E", "recommended_action"]],
            hide_index=True,
            width="stretch",
            column_config={"Count A/E": st.column_config.NumberColumn(format="%.1f%%")},
        )

with mortality_tab:
    st.subheader("Mortality A/E with statistical uncertainty")
    st.plotly_chart(mortality_trend_chart(mortality), width="stretch", key="mortality_trend")
    trend = mortality[mortality["analysis_name"] == "calendar_year"].copy()
    trend["Count A/E"] = 100 * trend["count_ae_ratio"]
    trend["Amount A/E"] = 100 * trend["amount_ae_ratio"]
    st.dataframe(
        trend[["dimension_1_value", "exposure", "actual_deaths", "expected_deaths", "Count A/E", "Amount A/E", "recommended_action"]],
        hide_index=True,
        width="stretch",
        column_config={
            "Count A/E": st.column_config.NumberColumn(format="%.1f%%"),
            "Amount A/E": st.column_config.NumberColumn(format="%.1f%%"),
        },
    )

with segment_tab:
    choices = [name for name in mortality["analysis_name"].drop_duplicates() if name != "portfolio"]
    selected = st.selectbox("Analysis view", choices, index=choices.index("age_duration"))
    minimum_exposure = st.slider("Minimum exposure", 0, 5000, 250, 250)
    segment = mortality[
        (mortality["analysis_name"] == selected)
        & (mortality["exposure"] >= minimum_exposure)
    ].copy()
    segment["segment"] = segment["dimension_1_value"].astype(str) + segment["dimension_2_value"].fillna("").map(
        lambda value: f" / {value}" if value else ""
    )
    fig = px.scatter(
        segment,
        x=100 * segment["count_ae_ratio"],
        y=100 * segment["amount_ae_ratio"],
        size="exposure",
        color="recommended_action",
        color_discrete_map=ACTION_COLORS,
        hover_name="segment",
        hover_data={"actual_deaths": True, "expected_deaths": ":.2f", "exposure": ":.1f"},
        labels={"x": "Count A/E (%)", "y": "Amount A/E (%)", "recommended_action": "Action"},
    )
    fig.add_hline(y=100, line_dash="dash", line_color="#64748b")
    fig.add_vline(x=100, line_dash="dash", line_color="#64748b")
    fig.update_layout(height=500)
    st.plotly_chart(fig, width="stretch", key="segment_scatter")

    if selected == "age_duration":
        heat = segment.pivot(index="dimension_1_value", columns="dimension_2_value", values="count_ae_ratio") * 100
        heat_fig = px.imshow(
            heat,
            text_auto=".1f",
            color_continuous_scale="RdYlGn_r",
            color_continuous_midpoint=100,
            labels={"color": "A/E %", "x": "Duration", "y": "Attained age"},
        )
        st.plotly_chart(heat_fig, width="stretch", key="age_duration_heatmap")

with lapse_tab:
    cols = st.columns(4)
    cols[0].metric("Actual lapses", f"{lapse_portfolio['actual_lapses']:,.0f}")
    cols[1].metric("Expected lapses", f"{lapse_portfolio['expected_lapses']:,.1f}")
    cols[2].metric("Lapse A/E", pct(lapse_portfolio["lapse_ae_ratio"]))
    cols[3].metric("Recommended action", lapse_portfolio["recommended_action"])
    lapse_trend = lapse[lapse["analysis_name"] == "calendar_year"].copy().sort_values("dimension_1_value")
    lapse_fig = px.line(
        lapse_trend,
        x="dimension_1_value",
        y=100 * lapse_trend["lapse_ae_ratio"],
        markers=True,
        labels={"dimension_1_value": "Calendar year", "y": "Lapse A/E (%)"},
    )
    lapse_fig.add_hline(y=100, line_dash="dash", line_color="#475569")
    lapse_fig.update_traces(line={"color": "#7c3aed", "width": 3})
    lapse_fig.update_layout(height=390)
    st.plotly_chart(lapse_fig, width="stretch", key="lapse_trend")

with controls_tab:
    failures = int(validation["failures"].sum())
    passed = int((validation["failures"] == 0).sum())
    cols = st.columns(3)
    cols[0].metric("Controls passed", f"{passed} / {len(validation)}")
    cols[1].metric("Total failures", f"{failures}")
    cols[2].metric("Control status", "PASS" if failures == 0 else "FAIL")
    st.dataframe(
        validation[["check_name", "failures", "checked_at"]],
        hide_index=True,
        width="stretch",
    )
