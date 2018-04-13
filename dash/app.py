
# life expectancy and income mobility
# dissertation
# author: sebastian daza

import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output
import dash_table_experiments as dt

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

lags_pred = pd.read_csv('data/lags_pred.csv')
lags_obs = pd.read_csv('data/lags_obs.csv')

lags_pred = lags_pred.groupby(['ctry', 'year', 'segment'],).describe(percentiles=[0.025, 0.50, .975])

lags_obs = lags_obs.groupby(['ctry', 'year', 'segment'],).describe(percentiles=[0.025, 0.50, .975])

lags_pred.reset_index(inplace=True)
lags_obs.reset_index(inplace=True)

lags_pred.columns = ['_'.join(tup).rstrip('_') for tup in lags_pred.columns.values]

lags_obs.columns = ['_'.join(tup).rstrip('_') for tup in lags_obs.columns.values]


lags_obs = lags_obs.loc[:, ['ctry', 'year', 'segment', 'pred_lag_2.5%',
                            'pred_lag_50%', 'pred_lag_97.5%']]

lags_pred = lags_pred.loc[:, ['ctry', 'year', 'segment', 'pred_lag_2.5%',
                            'pred_lag_50%', 'pred_lag_97.5%']]

lags_obs.columns = ['Country', 'Year', 'Segment', 'P(2.5)', 'P(50)', 'P(97.5)']
lags_pred.columns = ['Country', 'Year', 'Segment', 'P(2.5)', 'P(50)', 'P(97.5)']

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

segments = shift_pred.loc[(shift_pred.ctry=='Argentina') & (shift_pred.year==1950), 'segment'].unique()

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
fig_shift_pred['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (Predicted LE - Predicted Counterfactual LE)' ))
# fig_shift_pred['layout'].update(yaxis=dict(range=[0,1]))
fig_shift_pred['layout'].update(title='Argentina Shift for Year 1950 by Year Segment')

# obs

segments = shift_obs.loc[(shift_obs.ctry=='Argentina') & (shift_obs.year==1950), 'segment'].unique()

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
fig_shift_obs['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (Observed LE - Predicted Counterfactual LE)' ))
# fig_shift_obs['layout'].update(yaxis=dict(range=[0,1]))
fig_shift_obs['layout'].update(title='Argentina Shift for Year 1950 by Year Segment')


###################
# lag table
###################

# sel_lags_obs = lags_obs.loc[(lags_obs.ctry=='Argentina') & (lags_obs.year==1950),
#                   ['ctry', 'year', 'segment',
#                    'pred_lag_2.5%',
#                    'pred_lag_50%',                                       'pred_lag_97.5%']]
#
# sel_lags_pred = lags_pred.loc[(lags_pred.ctry=='Argentina') & (lags_pred.year==1950),
#                   ['ctry', 'year', 'segment',
#                    'pred_lag_2.5%',
#                    'pred_lag_50%',                                       'pred_lag_97.5%']]
#
# trace = go.Table(
#     header=dict(values=[['<b>Country</b>'],
#                   ['<b>Year</b>'],
#                   ['<b>Segment</b>'],
#                   ['<b>P(2.5)</b>'],
#                   ['<b>P(50)</b>'],
#                   ['<b>P(97.5)</b>']],
#                 fill = dict(color='#C2D4FF'),
#                 align = ['left'] * 5),
#     cells=dict(values=[sel_lags_pred.ctry, sel_lags_pred.year, sel_lags_pred.segment, sel_lags_pred['pred_lag_2.5%'], sel_lags_pred['pred_lag_50%'], sel_lags_pred['pred_lag_97.5%']],
#                fill = dict(color='#F5F8FF'),
#                align = ['left'] * 5))
#
# data = [trace]
# layout = dict(width=200, height=300)
# table_lags_pred = dict(data=data, layout=layout)
#
#
# trace = go.Table(
#     header=dict(values=[['<b>Country</b>'],
#                   ['<b>Year</b>'],
#                   ['<b>Segment</b>'],
#                   ['<b>P(2.5)</b>'],
#                   ['<b>P(50)</b>'],
#                   ['<b>P(97.5)</b>']],
#                 fill = dict(color='#C2D4FF'),
#                 align = ['left'] * 5),
#     cells=dict(values=[sel_lags_obs.ctry, sel_lags_obs.year, sel_lags_obs.segment, sel_lags_obs['pred_lag_2.5%'], sel_lags_obs['pred_lag_50%'], sel_lags_obs['pred_lag_97.5%']],
#                fill = dict(color='#F5F8FF'),
#                align = ['left'] * 5))
#
# data = [trace]
# layout = dict(width=200, height=300)
# table_lags_obs = dict(data=data, layout=layout)

#
# # pred
# segments = lag_pred.loc[(lag_pred.ctry=='Argentina'), 'year'].unique()
#
# hist_data = []
#
# for i in segments:
#     hist_data.append(lag_pred.loc[(lag_pred.ctry=='Argentina') & (lag_pred.year==i), 'pred_lag'].tolist())
#
# group_labels = segments
# colors = []
# for i in segments:
#     colors.append(dict_colors_lags[i])
#
# fig_lag_pred = ff.create_distplot(hist_data,
#                          group_labels=group_labels,
#                          curve_type='kde',
#                          show_hist=False,
#                          show_curve=True,
#                          show_rug=False,
#                          bin_size=0.2,
#                          colors=colors)
#
# fig_lag_pred['layout'].update(legend=dict(orientation='h', x=0.25, y=1.15, traceorder='normal'))
# fig_lag_pred['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (mean predicted values)' ))
# # fig_lag_pred['layout'].update(yaxis=dict(range=[0,1]))
# fig_lag_pred['layout'].update(title='Argentina Lags')
#
# # obs
#
# segments = lag_obs.loc[(lag_obs.ctry=='Argentina'), 'year'].unique()
#
# hist_data = []
#
# for i in segments:
#     hist_data.append(lag_obs.loc[(lag_obs.ctry=='Argentina') &  (lag_obs.year==i), 'pred_lag'].tolist())
#
#
# group_labels = segments
# colors = []
# for i in segments:
#     colors.append(dict_colors_lags[i])
#
# fig_lag_obs = ff.create_distplot(hist_data,
#                          group_labels=group_labels,
#                          curve_type='kde',
#                          show_hist=False,
#                          show_rug=False,
#                          colors=colors)
#
# fig_lag_obs['layout'].update(legend=dict(orientation='h', x=0.25, y=1.15, traceorder='normal'))
# fig_lag_obs['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (observed values)' ))
# # fig_lag_obs['layout'].update(yaxis=dict(range=[0,1]))
# fig_lag_obs['layout'].update(title='Argentina Lags')


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
        xaxis=dict(title='Year', range=[np.min(pred.year)-5, np.max(pred.year)+5]),
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
    - Average LE (sex) and data only since 1900
    - Intercept varies by country and year
    - GDP coefficient varies by country and year
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
                )], style= {'maxWidth': '200px', 'margin': '0px auto'}),
                    ]),
              html.Div('', style={'padding': 10}),
        html.Div([
                 dcc.Graph(id='pred_le', figure=pred_le)], style={'margin':'auto', 'height': '500px', 'maxWidth': '700px'}),
                html.Div('', style={'padding': -50}),
              html.H3('Shifts',
                    style={'textAlign':'center'}),
         dcc.Markdown('''
         - Each counterfactual LE for given year **t** is based on a year segment **j** (e.g., 1950-1969). That is, the intercept and slope of period **j** and GDP value of year **t**
         - Predicted LE values (non-counterfactual) correspond to the predicted LE values show in the first plot (prediction checks)
         - Lines represent the difference between predicted LE values (non-counterfactual) and counterfactual values using **always** GDP of year **t**
         - If year t = 1950, the red line (<1950) represents the difference between predicted LE values for 1950 and (counterfactual) LE values if both intercept and slope would remain as before 1950 but with the GDP levels of 1950
             '''.replace('  ', ''), className='container',
             containerProps={'style': {'maxWidth': '650px'}}),
        html.Div('', style={'padding': 10}),
          html.Div([
               html.Label('Year (t)'),
               dcc.Dropdown(
                   id='year_selector'
                   # ,
                   # options=[{'label': i, 'value': j} for i,j in dict_years.items()],
                   # value=1950
                   )
           ], style= {'maxWidth': '200px', 'margin': '0px auto'}),
         html.Div([
            html.Div([dcc.Graph(id='density_shift_obs', figure=fig_shift_obs)], className='six columns'),
            html.Div([dcc.Graph(id='density_shift_pred', figure=fig_shift_pred)], className='six columns'),
            ], className='row'),
            html.Div('', style={'padding': 10}),
            html.H3('Lags',
                    style={'textAlign':'center'}),
            dcc.Markdown('''
            - Either using observed or predicted LE values (prediction checks plot), we get two vectors (LE values, years)
            - We use the mean of predicted values (blue line in the first plot)
            - We compute a counterfactual for year **t** using the intercept   and slope of period **j** and GDP values of year **t**
            - Values represent the difference between year **t** and the year with the smallest difference between observed/predicted LE values (average) and counterfactual LE values
                '''.replace('  ', ''), className='container',
                containerProps={'style': {'maxWidth': '650px'}}),
            html.Div([
                html.H5('Observed'),
                html.Div([dt.DataTable(
                rows=lags_obs.loc[(lags_obs.Country=='Argentina') & (lags_obs.Year==1950)].to_dict('records'),
                filterable=False,
                sortable=True,
                row_selectable=False,
                min_height=150,
                id='table_lags_obs')])], style={'margin':'auto', 'height': '300px', 'maxWidth': '600px'}),
             html.Div('', style={'padding': -15}),
            html.Div([
                html.H5('Predicted'),
                html.Div([dt.DataTable(
                rows=lags_pred.loc[(lags_pred.Country=='Argentina') & (lags_pred.Year==1950)].to_dict('records'),
                filterable=False,
                sortable=True,
                row_selectable=False,
                min_height=150,
                id='table_lags_pred')])], style={'margin':'auto', 'height': '400px', 'maxWidth': '600px'}),

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
            xaxis=dict(title='Year', range=[np.min(pred.year)-5, np.max(pred.year)+5]),
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

    segments = shift_pred.loc[(shift_pred.ctry==country_selector) &
                              (shift_pred.year==year_selector), 'segment'].unique()

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

    fig_shift_pred['layout'].update(legend=dict(orientation='h', x=0.2, y=1.15, traceorder='normal'))
    fig_shift_pred['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (Predicted LE - Predicted Counterfactual LE)' ))
    # fig_shift_pred['layout'].update(yaxis=dict(range=[0,1]))
    fig_shift_pred['layout'].update(title=dict_countries[country_selector] + ' Shift for Year ' + str(year_selector) + ' by Year Segment')

    return fig_shift_pred

# observed

@app.callback(
    dash.dependencies.Output('density_shift_obs', 'figure'),
    [dash.dependencies.Input('country_selector','value'),
     dash.dependencies.Input('year_selector','value')])

def update_density_shift_obs(country_selector, year_selector):

    segments = shift_obs.loc[(shift_obs.ctry==country_selector) &
                              (shift_obs.year==year_selector), 'segment'].unique()

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

    fig_shift_obs['layout'].update(legend=dict(orientation='h', x=0.2, y=1.15, traceorder='normal'))
    fig_shift_obs['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (Observed LE - Predicted Counterfactual LE)' ))
    # fig_shift_obs['layout'].update(yaxis=dict(range=[0,1]))
    fig_shift_obs['layout'].update(title=dict_countries[country_selector] + ' Shift for Year ' + str(year_selector) + ' by Year Segment')

    return fig_shift_obs

# update lag tables

@app.callback(
    Output(component_id='table_lags_obs', component_property='rows'),
    [dash.dependencies.Input('country_selector','value'),
     dash.dependencies.Input('year_selector','value')])

def update_table_lags_obs(country_selector, year_selector):
    return lags_obs.loc[(lags_obs.Country==country_selector) & (lags_obs.Year==year_selector)].to_dict('records')

@app.callback(
    Output(component_id='table_lags_pred', component_property='rows'),
    [dash.dependencies.Input('country_selector','value'),
     dash.dependencies.Input('year_selector','value')])

def update_table_lags_pred(country_selector, year_selector):
    return lags_pred.loc[(lags_pred.Country==country_selector) & (lags_pred.Year==year_selector)].to_dict('records')



# predicted

    # segments = lag_pred.loc[(lag_pred.ctry==country_selector), 'year'].unique()
    #
    # hist_data = []
    #
    # for i in segments:
    #     hist_data.append(lag_pred.loc[(lag_pred.ctry==country_selector) &
    #                                     (lag_pred.year==i), 'pred_lag'].values.tolist())
    # group_labels = segments
    # colors = []
    # for i in segments:
    #     colors.append(dict_colors_lags[i])
    #
    # fig_lag_pred = ff.create_distplot(hist_data,
    #                          group_labels=group_labels,
    #                          curve_type='kde',
    #                          show_hist=False,
    #                          show_curve=True,
    #                          show_rug=False,
    #                          bin_size=0.8,
    #                          colors=colors)
    #
    # fig_lag_pred['layout'].update(legend=dict(orientation='h', x=0.25, y=1.15, traceorder='normal'))
    # fig_lag_pred['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (mean predicted values)' ))
    # # fig_lag_pred['layout'].update(yaxis=dict(range=[0,1]))
    # fig_lag_pred['layout'].update(title=dict_countries[country_selector] + ' Lags')
    #
    # return fig_lag_pred

# observed

# @app.callback(
#     dash.dependencies.Output('table_lag_obs', 'figure'),
#     [dash.dependencies.Input('country_selector','value')])
#
# def update_table_lag_obs(country_selector):
#
#     segments = lag_obs.loc[(lag_obs.ctry==country_selector), 'year'].unique()
#
#     hist_data = []
#
#     for i in segments:
#         hist_data.append(lag_obs.loc[(lag_obs.ctry==country_selector) &
#                                         (lag_obs.year==i), 'pred_lag'].values.tolist())
#     group_labels = segments
#     colors = []
#     for i in segments:
#         colors.append(dict_colors_lags[i])
#
#     fig_lag_obs = ff.create_distplot(hist_data,
#                              group_labels=group_labels,
#                              curve_type='kde',
#                              show_hist=False,
#                              show_rug=False,
#                              colors=colors)
#
#     fig_lag_obs['layout'].update(legend=dict(orientation='h', x=0.25, y=1.15, traceorder='normal'))
#     fig_lag_obs['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years (observed values)' ))
#     # fig_lag_obs['layout'].update(yaxis=dict(range=[0,1]))
#     fig_lag_obs['layout'].update(title=dict_countries[country_selector] + ' Lags')
#
#     return fig_lag_obs


# css
external_css = ["https://cdnjs.cloudflare.com/ajax/libs/skeleton/2.0.4/skeleton.min.css",
                "//fonts.googleapis.com/css?family=Raleway:400,300,600",
                "//fonts.googleapis.com/css?family=Dosis:Medium"]


for css in external_css:
    app.css.append_css({"external_url": css})


if __name__ == '__main__':
    app.run_server(debug=True)
