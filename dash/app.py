
# life expectancy and income mobility
# dissertation
# author: sebastian daza

import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output
# import dash_table_experiments as dt

import plotly.graph_objs as go
import plotly.figure_factory as ff
import plotly.plotly as py
import flask
import os

import pandas as pd
import scipy
import numpy as np
from textwrap import dedent as s

app = dash.Dash(__name__)
server = app.server
server.secret_key = os.environ.get('secret_key', 'secret')

app.title='Lambda: Shifts and Lags'

# get data

shift_pred = pd.read_csv('data/shifts_pred.csv')
shift_obs = pd.read_csv('data/shifts_obs.csv')
lag_pred = pd.read_csv('data/lags_pred.csv')
lag_obs = pd.read_csv('data/lags_obs.csv')

pred = pd.read_csv('data/pred.csv')

# menus

countries = shift_pred.ctry.unique()
label_countries = [w.replace('_', ' ') for w in countries]
dict_countries = dict(zip(countries, label_countries))

# colors
dict_colors_shift = dict(zip(['<1950', '1950-1969', '1970-1989', '>=1990'],
                       ['#e34a33', '#2b8cbe', '#31a354', '#fdae6b']))

dict_colors_lags = dict(zip([1950, 1970, 1990],
                       ['#e34a33', '#2b8cbe', '#31a354']))

all_options = dict()

for c in countries:
    l = shift_pred.loc[(shift_pred.ctry==c), 'year'].unique().tolist()
    s = shift_pred.loc[(shift_pred.ctry==c), 'segment'].unique().tolist()
    td = {c : {'year':l, 'segment':s}}
    all_options.update(td)


###################
# shift densities
###################


# pred

segments = shift_pred.loc[(shift_pred.ctry=='Argentina'), 'segment'].unique()

hist_data = []

for i in segments:
    hist_data.append(shift_pred.loc[(shift_pred.ctry=='Argentina') &
                                    (shift_pred.year==1950) & (shift_pred.segment==i), 'pred_shift'].tolist()
                     )


group_labels = segments
colors = []
for i in segments:
    colors.append(dict_colors_shift[i])

fig_shift_pred = ff.create_distplot(hist_data,
                         group_labels=group_labels,
                         curve_type='kde',
                         show_hist=False,
                         show_curve=True,
                         show_rug=False,
                         bin_size=0.2,
                         colors=colors)

fig_shift_pred['layout'].update(legend=dict(orientation='h', x=0.1, y=1.15, traceorder='normal'))
fig_shift_pred['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (Predicted LE - Predicted LE)' ))
# fig_shift_pred['layout'].update(yaxis=dict(range=[0,1]))
fig_shift_pred['layout'].update(title='Argentina Shift for Year 1950 by Year Segment')

# obs

segments = shift_obs.loc[(shift_obs.ctry=='Argentina'), 'segment'].unique()

hist_data = []

for i in segments:
    hist_data.append(shift_obs.loc[(shift_obs.ctry=='Argentina') &
                                    (shift_obs.year==1950) & (shift_obs.segment==i), 'pred_shift'].tolist()
                     )


group_labels = segments
colors = []
for i in segments:
    colors.append(dict_colors_shift[i])

fig_shift_obs = ff.create_distplot(hist_data,
                         group_labels=group_labels,
                         curve_type='kde',
                         show_hist=False,
                         show_rug=False,
                         colors=colors)

fig_shift_obs['layout'].update(legend=dict(orientation='h', x=0.1, y=1.15, traceorder='normal'))
fig_shift_obs['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (Observed LE - Predicted LE)' ))
# fig_shift_obs['layout'].update(yaxis=dict(range=[0,1]))
fig_shift_obs['layout'].update(title='Argentina Shift for Year 1950 by Year Segment')


###################
# lag densities
###################


# pred
segments = lag_pred.loc[(lag_pred.ctry=='Argentina'), 'year'].unique()

hist_data = []

for i in segments:
    hist_data.append(lag_pred.loc[(lag_pred.ctry=='Argentina') & (lag_pred.year==i), 'pred_lag'].tolist())

group_labels = segments
colors = []
for i in segments:
    colors.append(dict_colors_lags[i])

fig_lag_pred = ff.create_distplot(hist_data,
                         group_labels=group_labels,
                         curve_type='kde',
                         show_hist=False,
                         show_curve=True,
                         show_rug=False,
                         bin_size=0.2,
                         colors=colors)

fig_lag_pred['layout'].update(legend=dict(orientation='h', x=0.25, y=1.15, traceorder='normal'))
fig_lag_pred['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (mean predicted values)' ))
# fig_lag_pred['layout'].update(yaxis=dict(range=[0,1]))
fig_lag_pred['layout'].update(title='Argentina Lags')

# obs

segments = lag_obs.loc[(lag_obs.ctry=='Argentina'), 'year'].unique()

hist_data = []

for i in segments:
    hist_data.append(lag_obs.loc[(lag_obs.ctry=='Argentina') &  (lag_obs.year==i), 'pred_lag'].tolist())


group_labels = segments
colors = []
for i in segments:
    colors.append(dict_colors_lags[i])

fig_lag_obs = ff.create_distplot(hist_data,
                         group_labels=group_labels,
                         curve_type='kde',
                         show_hist=False,
                         show_rug=False,
                         colors=colors)

fig_lag_obs['layout'].update(legend=dict(orientation='h', x=0.25, y=1.15, traceorder='normal'))
fig_lag_obs['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (observed values)' ))
# fig_lag_obs['layout'].update(yaxis=dict(range=[0,1]))
fig_lag_obs['layout'].update(title='Argentina Lags')


# model plot

upper_bound = go.Scatter(
    name='Upper Bound',
    x=pred.loc[(pred.ctry=='Argentina'), 'year'],
    y=pred.loc[(pred.ctry=='Argentina'), 'hi'],
    mode='lines',
    marker=dict(color="444"),
    line=dict(width=0),
    fillcolor='rgba(68, 68, 68, 0.3)',
    fill='tonexty')

points = go.Scatter(
    name='Observed LE',
    x=pred.loc[(pred.ctry=='Argentina'), 'year'],
    y=pred.loc[(pred.ctry=='Argentina'), 'le'],
    mode='markers',
    marker=dict(opacity=0.5))

trace = go.Scatter(
    name='Predicted LE',
    x=pred.loc[(pred.ctry=='Argentina'), 'year'],
    y=pred.loc[(pred.ctry=='Argentina'), 'm'],
    mode='lines',
    line=dict(color='rgb(31, 119, 180)'),
    fillcolor='rgba(68, 68, 68, 0.3)',
    fill='tonexty')

lower_bound = go.Scatter(
    name='Lower Bound',
    x=pred.loc[(pred.ctry=='Argentina'), 'year'],
    y=pred.loc[(pred.ctry=='Argentina'), 'lo'],
    marker=dict(color="444"),
    line=dict(width=0),
    mode='lines')

data = [lower_bound, trace, upper_bound, points]

layout = go.Layout(
        yaxis=dict(title='LE', range=[np.min(np.append(pred['le'], pred['lo'])), np.max(np.append(pred['le'], pred['hi']))]),
        xaxis=dict(title='Year', range=[np.min(pred.year), np.max(pred.year)]),
    title='Argentina Observed vs Predicted LE',
    showlegend = False)

pred_le = go.Figure(data=data, layout=layout)


###################################
# app layout
##################################

app.layout = html.Div(children=[
         html.Div('', style={'padding': 10}),
         html.H2('Lambda: Shifts and Lags',
                    style={'textAlign':'center'}),
         html.Div('', style={'padding': 20}),
        #     # html.H5('by Sebastian Daza',
        #             # style={'textAlign': 'center'}),
    dcc.Markdown('''
    Plots created using random intercerpt and coefficient model:
    - Intercept varies by country and year
    - GPD coefficient varies by country and year
    - [Code of models available here](https://github.com/sdaza/lambda/blob/master/notebooks/counterfactuals.ipynb)

    ---
    '''.replace('  ', ''), className='container',
    containerProps={'style': {'maxWidth': '650px'}}),
        html.Div('', style={'padding': 10}),
        html.H3('Prediction Checks',
                            style={'textAlign':'center'}),
        html.Div('', style={'padding': 10}),
         html.Div([
            html.Div([
                html.Label('Country'),
                dcc.Dropdown(
                    id='country_selector',
                    options=[{'label': j, 'value': i} for i,j in dict_countries.items()],
                    value='Argentina'
                )], className='six columns', style= {'maxWidth': '200px', 'margin-left': '35%'}),
            html.Div([
                html.Label('Year'),
                dcc.Dropdown(
                    id='year_selector'
                    # ,
                    # options=[{'label': i, 'value': j} for i,j in dict_years.items()],
                    # value=1950
                    )
            ], className='row', style= {'maxWidth': '100px', 'margin-left': '55%'}),
                    ]),
              html.Div('', style={'padding': 10}),
        html.Div([
                 dcc.Graph(id='pred_le', figure=pred_le)], style={'margin':'auto', 'height': '500px', 'maxWidth': '700px'}),
                html.Div('', style={'padding': -50}),
              html.H3('Shifts',
                    style={'textAlign':'center'}),
         dcc.Markdown('''
         - Each predicted value for year *t* is based on the corresponding year segment (lines).
         - Figure in the right compute differences between predicted and observed values.
         - Figure in the left constrasts only predicted values.
             '''.replace('  ', ''), className='container',
             containerProps={'style': {'maxWidth': '650px'}}),
         html.Div([
            html.Div([dcc.Graph(id='density_shift_obs', figure=fig_shift_obs)], className='six columns'),
            html.Div([dcc.Graph(id='density_shift_pred', figure=fig_shift_pred)], className='six columns'),
            ], className='row'),
            html.Div('', style={'padding': -20}),
            html.H3('Lags',
                    style={'textAlign':'center'}),
            dcc.Markdown('''
            - Each predicted value for year *t* is based on the previous year segment. For instance, 1950 uses the coefficient estimate for segment <1950.
            - Figure in the right matches predicted values with the closest LE observed value.
            - Figure in the left matches predicted values with the closest average of predicted values.

                '''.replace('  ', ''), className='container',
                containerProps={'style': {'maxWidth': '650px'}}),
            html.Div([
            html.Div([dcc.Graph(id='density_lag_obs', figure=fig_lag_obs)], className='six columns'),
            html.Div([dcc.Graph(id='density_lag_pred', figure=fig_lag_pred)], className='six columns'),
            ], className='row'),

         # html.Div('', style={'padding': -20}),
         # html.Div([dcc.Graph(id='pred_le', figure=pred_le)],
         #           style={'margin':'auto', 'height': '600px', 'maxWidth': '800px'})
                 html.Div('', style={'padding': 50})
         ])

# update menus

@app.callback(
    dash.dependencies.Output('year_selector', 'options'),
    [dash.dependencies.Input('country_selector', 'value')])
def set_year_options(country_selector):
    return [{'label': i, 'value': i} for i in all_options[country_selector]['year']]

@app.callback(
    dash.dependencies.Output('year_selector', 'value'),
    [dash.dependencies.Input('year_selector', 'options')])
def set_year_value(available_options):
    return available_options[0]['value']

# update prediction plot

@app.callback(
    dash.dependencies.Output('pred_le', 'figure'),
    [dash.dependencies.Input('country_selector','value')])

def update_model_plot(country_selector):

    upper_bound = go.Scatter(
        name='Upper Bound',
        x=pred.loc[(pred.ctry==country_selector), 'year'],
        y=pred.loc[(pred.ctry==country_selector), 'hi'],
        mode='lines',
        marker=dict(color="444"),
        line=dict(width=0),
        fillcolor='rgba(68, 68, 68, 0.3)',
        fill='tonexty')

    points = go.Scatter(
        name='Observed LE',
        x=pred.loc[(pred.ctry==country_selector), 'year'],
        y=pred.loc[(pred.ctry==country_selector), 'le'],
        mode='markers',
        marker=dict(opacity=0.5))

    trace = go.Scatter(
        name='Predicted LE',
        x=pred.loc[(pred.ctry==country_selector), 'year'],
        y=pred.loc[(pred.ctry==country_selector), 'm'],
        mode='lines',
        line=dict(color='rgb(31, 119, 180)'),
        fillcolor='rgba(68, 68, 68, 0.3)',
        fill='tonexty')

    lower_bound = go.Scatter(
        name='Lower Bound',
        x=pred.loc[(pred.ctry==country_selector), 'year'],
        y=pred.loc[(pred.ctry==country_selector), 'lo'],
        marker=dict(color="444"),
        line=dict(width=0),
        mode='lines')

    data = [lower_bound, trace, upper_bound, points]

    layout = go.Layout(
            yaxis=dict(title='LE', range=[np.min(np.append(pred['le'], pred['lo'])), np.max(np.append(pred['le'], pred['hi']))]),
            xaxis=dict(title='Year', range=[np.min(pred.year), np.max(pred.year)]),
        title=dict_countries[country_selector] + ' Observed vs Predicted LE',
        showlegend = False)

    return go.Figure(data=data, layout=layout)

# update shift plots

# predicted

@app.callback(
    dash.dependencies.Output('density_shift_pred', 'figure'),
    [dash.dependencies.Input('country_selector','value'),
     dash.dependencies.Input('year_selector','value')])

def update_density_shift_pred(country_selector, year_selector):

    segments = shift_pred.loc[(shift_pred.ctry==country_selector), 'segment'].unique()

    hist_data = []

    for i in segments:
        hist_data.append(shift_pred.loc[(shift_pred.ctry==country_selector) &
                                        (shift_pred.year==year_selector) & (shift_pred.segment==i), 'pred_shift'].values.tolist())
    group_labels = segments
    colors = []
    for i in segments:
        colors.append(dict_colors_shift[i])

    fig_shift_pred = ff.create_distplot(hist_data,
                             group_labels=group_labels,
                             curve_type='kde',
                             show_hist=False,
                             show_rug=False,
                             colors=colors)

    fig_shift_pred['layout'].update(legend=dict(orientation='h', x=0.1, y=1.15, traceorder='normal'))
    fig_shift_pred['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (Predicted LE - Predicted LE)' ))
    # fig_shift_pred['layout'].update(yaxis=dict(range=[0,1]))
    fig_shift_pred['layout'].update(title=dict_countries[country_selector] + ' Shift for Year ' + str(year_selector) + ' by Year Segment')

    return fig_shift_pred

# observed

@app.callback(
    dash.dependencies.Output('density_shift_obs', 'figure'),
    [dash.dependencies.Input('country_selector','value'),
     dash.dependencies.Input('year_selector','value')])

def update_density_shift_obs(country_selector, year_selector):

    segments = shift_obs.loc[(shift_obs.ctry==country_selector), 'segment'].unique()

    hist_data = []

    for i in segments:
        hist_data.append(shift_obs.loc[(shift_obs.ctry==country_selector) &
                                        (shift_obs.year==year_selector) & (shift_obs.segment==i), 'pred_shift'].values.tolist())
    group_labels = segments
    colors = []
    for i in segments:
        colors.append(dict_colors_shift[i])

    fig_shift_obs = ff.create_distplot(hist_data,
                             group_labels=group_labels,
                             curve_type='kde',
                             show_hist=False,
                             show_rug=False,
                             colors=colors)

    fig_shift_obs['layout'].update(legend=dict(orientation='h', x=0.1, y=1.15, traceorder='normal'))
    fig_shift_obs['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (Observed LE - Predicted LE)' ))
    # fig_shift_obs['layout'].update(yaxis=dict(range=[0,1]))
    fig_shift_obs['layout'].update(title=dict_countries[country_selector] + ' Shift for Year ' + str(year_selector) + ' by Year Segment')

    return fig_shift_obs

# update lag plots

# predicted

@app.callback(
    dash.dependencies.Output('density_lag_pred', 'figure'),
    [dash.dependencies.Input('country_selector','value')])

def update_density_lag_pred(country_selector):

    segments = lag_pred.loc[(lag_pred.ctry==country_selector), 'year'].unique()

    hist_data = []

    for i in segments:
        hist_data.append(lag_pred.loc[(lag_pred.ctry==country_selector) &
                                        (lag_pred.year==i), 'pred_lag'].values.tolist())
    group_labels = segments
    colors = []
    for i in segments:
        colors.append(dict_colors_lags[i])

    fig_lag_pred = ff.create_distplot(hist_data,
                             group_labels=group_labels,
                             curve_type='kde',
                             show_hist=False,
                             show_curve=True,
                             show_rug=False,
                             bin_size=0.8,
                             colors=colors)

    fig_lag_pred['layout'].update(legend=dict(orientation='h', x=0.25, y=1.15, traceorder='normal'))
    fig_lag_pred['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (mean predicted values)' ))
    # fig_lag_pred['layout'].update(yaxis=dict(range=[0,1]))
    fig_lag_pred['layout'].update(title=dict_countries[country_selector] + ' Lags')

    return fig_lag_pred

# observed

@app.callback(
    dash.dependencies.Output('density_lag_obs', 'figure'),
    [dash.dependencies.Input('country_selector','value')])

def update_density_lag_obs(country_selector):

    segments = lag_obs.loc[(lag_obs.ctry==country_selector), 'year'].unique()

    hist_data = []

    for i in segments:
        hist_data.append(lag_obs.loc[(lag_obs.ctry==country_selector) &
                                        (lag_obs.year==i), 'pred_lag'].values.tolist())
    group_labels = segments
    colors = []
    for i in segments:
        colors.append(dict_colors_lags[i])

    fig_lag_obs = ff.create_distplot(hist_data,
                             group_labels=group_labels,
                             curve_type='kde',
                             show_hist=False,
                             show_rug=False,
                             colors=colors)

    fig_lag_obs['layout'].update(legend=dict(orientation='h', x=0.25, y=1.15, traceorder='normal'))
    fig_lag_obs['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (observed values)' ))
    # fig_lag_obs['layout'].update(yaxis=dict(range=[0,1]))
    fig_lag_obs['layout'].update(title=dict_countries[country_selector] + ' Lags')

    return fig_lag_obs


# css
external_css = ["https://cdnjs.cloudflare.com/ajax/libs/skeleton/2.0.4/skeleton.min.css",
                "//fonts.googleapis.com/css?family=Raleway:400,300,600",
                "//fonts.googleapis.com/css?family=Dosis:Medium"]


for css in external_css:
    app.css.append_css({"external_url": css})


if __name__ == '__main__':
    app.run_server(debug=True)
