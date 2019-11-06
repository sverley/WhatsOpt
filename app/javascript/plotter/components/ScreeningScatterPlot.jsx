import React from 'react';
import PropTypes from 'prop-types';
// import Plot from 'react-plotly.js';
import createPlotlyComponent from 'react-plotly.js/factory';
import Plotly from './custom-plotly';

const Plot = createPlotlyComponent(Plotly);

class ScreeningScatterPlot extends React.PureComponent {
  render() {
    const { saData, outVarName } = this.props;
    const trace = {
      x: saData.mu_star,
      y: saData.sigma,
      type: 'scatter',
      mode: 'markers+text',
      text: saData.names,
      textposition: 'top center',
      marker: { size: 10 },
      cliponaxis: false,
    };

    const data = [trace];
    const layout = {
      title: `${outVarName} sensitivity`,
      width: 500,
      height: 500,
      xaxis: {
        rangemode: 'tozero',
        title: { text: '\u03BC*' },
        layer: 'below traces',
      },
      yaxis: {
        rangemode: 'tozero',
        title: { text: '\u03c3' },
        layer: 'below traces',
      },
    };

    return (<Plot data={data} layout={layout} />);
  }
}

ScreeningScatterPlot.propTypes = {
  outVarName: PropTypes.string.isRequired,
  saData: PropTypes.shape({
    mu_star: PropTypes.array.isRequired,
    sigma: PropTypes.array.isRequired,
    names: PropTypes.array.isRequired,
  }).isRequired,
};

export default ScreeningScatterPlot;
