
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

df = pd.read_csv('data/shifts.csv')
pred = pd.read_csv('data/pred.csv')

# menus

countries = df.ctry.unique()
label_countries = [w.replace('_', ' ') for w in countries]
dict_countries = dict(zip(countries, label_countries))
# dict_years = {'1950':1950, '1970':1970, '1990':1990, '2010':2010}
dict_sex = {'Male':'male', 'Female':'female', 'Average':'total'}
dict_sex_inv = {'male':'Male', 'female':'Female', 'total':'Average'}
all_options = dict()

for c in countries:
    l = df.loc[(df.ctry==c) & (df.sex=='total'), 'year'].unique().tolist()
    s = df.loc[(df.ctry==c) & (df.sex=='total'), 'segment'].unique().tolist()
    td = {c : {'year':l, 'segment':s}}
    all_options.update(td)


###################
# shift densities
###################

x1 = df.loc[(df.ctry=='Argentina') & (df.year==1950) & (df.segment=='<1950') & (df.sex=='total'), 'pred_shift'].values
x2 = df.loc[(df.ctry=='Argentina') & (df.year==1950) & (df.segment=='1950-1969') & (df.sex=='total'), 'pred_shift'].values
x3 = df.loc[(df.ctry=='Argentina') & (df.year==1950) & (df.segment=='1970-1989') & (df.sex=='total'), 'pred_shift'].values
x4 = df.loc[(df.ctry=='Argentina') & (df.year==1950) & (df.segment=='>=1990') & (df.sex=='total'), 'pred_shift'].values

hist_data = [x1,x2,x3,x4]
group_labels = ['<1950', '1950-1969', '1970-1989', '>=1990']
colors = ['#e34a33', '#2b8cbe', '#31a354', '#fdae6b']

fig = ff.create_distplot(hist_data,
                         group_labels=group_labels,
                         curve_type='kde',
                         show_hist=False,
                         show_rug=False,
                         colors=colors)

fig['layout'].update(legend=dict(orientation='h', x=0.1, y=1.15, traceorder='normal'))
fig['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years' ))
fig['']
# fig['layout'].update(yaxis=dict(range=[0,1]))
fig['layout'].update(title='Argentina Shift in Year 1950 by Year Segment (Male)')

# model plot

upper_bound = go.Scatter(
    name='Upper Bound',
    x=pred.loc[(pred.ctry=='Argentina') & (pred.sex=='male'), 'year'],
    y=pred.loc[(pred.ctry=='Argentina') & (pred.sex=='male'), 'hi'],
    mode='lines',
    marker=dict(color="444"),
    line=dict(width=0),
    fillcolor='rgba(68, 68, 68, 0.3)',
    fill='tonexty')

points = go.Scatter(
    name='Observed LE',
    x=pred.loc[(pred.ctry=='Argentina') & (pred.sex=='male'), 'year'],
    y=pred.loc[(pred.ctry=='Argentina') & (pred.sex=='male'), 'le'],
    mode='markers',
    marker=dict(opacity=0.5))

trace = go.Scatter(
    name='Predicted LE',
    x=pred.loc[(pred.ctry=='Argentina') & (pred.sex=='male'), 'year'],
    y=pred.loc[(pred.ctry=='Argentina') & (pred.sex=='male'), 'm'],
    mode='lines',
    line=dict(color='rgb(31, 119, 180)'),
    fillcolor='rgba(68, 68, 68, 0.3)',
    fill='tonexty')

lower_bound = go.Scatter(
    name='Lower Bound',
    x=pred.loc[(pred.ctry=='Argentina') & (pred.sex=='male'), 'year'],
    y=pred.loc[(pred.ctry=='Argentina') & (pred.sex=='male'), 'lo'],
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
        #  html.Div('', style={'padding': 20}),
        #     # html.H5('by Sebastian Daza',
        #             # style={'textAlign': 'center'}),
        # dcc.Markdown(s('''
        # Distribution from models using only GDP (incomplete cases removed):
        #
        #
        # 1. Shift for year *t* (Year) given model *j* (segments)
        # 2. Predicted vs observed values
        # 3. Pending lags
        # '''),  className='container', containerProps={'style': {'maxWidth': '650px'}}
        # ),
        html.Div('', style={'padding': 10}),
         html.Div([
            html.Div([
                html.Label('Country'),
                dcc.Dropdown(
                    id='country_selector',
                    options=[{'label': j, 'value': i} for i,j in dict_countries.items()],
                    value='Argentina'
                )], className='three columns', style= {'maxWidth': '200px', 'margin-left': '30%'}),
            html.Div([
                html.Label('Year'),
                dcc.Dropdown(
                    id='year_selector'
                    # ,
                    # options=[{'label': i, 'value': j} for i,j in dict_years.items()],
                    # value=1950
                    )
            ], className='two columns', style= {'maxWidth': '100px'}),
            html.Div([
                html.Label('Sex'),
                dcc.RadioItems(
                    id='sex_selector',
                    options=[{'label': i, 'value': j} for i,j in dict_sex.items()],
                    value='male', labelStyle={'display': 'inline-block'})
                ], className='row', style= {'margin-left': '60%'}),
                    ]),
              html.Div('', style={'padding': 10}),
         html.Div([
            html.Div([
                 dcc.Graph(id='pred_le', figure=pred_le)], className='six columns'),
            html.Div([dcc.Graph(id='density_shifts', figure=fig)], className='six columns')],  className='row'),
         # html.Div('', style={'padding': -20}),
         # html.Div([dcc.Graph(id='pred_le', figure=pred_le)],
         #           style={'margin':'auto', 'height': '600px', 'maxWidth': '800px'})
         ])

# update scatter plot

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


@app.callback(
    dash.dependencies.Output('pred_le', 'figure'),
    [dash.dependencies.Input('country_selector','value'),
     dash.dependencies.Input('sex_selector','value')])

def update_model_plot(country_selector,
                            sex_selector):

    upper_bound = go.Scatter(
        name='Upper Bound',
        x=pred.loc[(pred.ctry==country_selector) & (pred.sex==sex_selector), 'year'],
        y=pred.loc[(pred.ctry==country_selector) & (pred.sex==sex_selector), 'hi'],
        mode='lines',
        marker=dict(color="444"),
        line=dict(width=0),
        fillcolor='rgba(68, 68, 68, 0.3)',
        fill='tonexty')

    points = go.Scatter(
        name='Observed LE',
        x=pred.loc[(pred.ctry==country_selector) & (pred.sex==sex_selector), 'year'],
        y=pred.loc[(pred.ctry==country_selector) & (pred.sex==sex_selector), 'le'],
        mode='markers',
        marker=dict(opacity=0.5))

    trace = go.Scatter(
        name='Predicted LE',
        x=pred.loc[(pred.ctry==country_selector) & (pred.sex==sex_selector), 'year'],
        y=pred.loc[(pred.ctry==country_selector) & (pred.sex==sex_selector), 'm'],
        mode='lines',
        line=dict(color='rgb(31, 119, 180)'),
        fillcolor='rgba(68, 68, 68, 0.3)',
        fill='tonexty')

    lower_bound = go.Scatter(
        name='Lower Bound',
        x=pred.loc[(pred.ctry==country_selector) & (pred.sex==sex_selector), 'year'],
        y=pred.loc[(pred.ctry==country_selector) & (pred.sex==sex_selector), 'lo'],
        marker=dict(color="444"),
        line=dict(width=0),
        mode='lines')

    data = [lower_bound, trace, upper_bound, points]

    layout = go.Layout(
            yaxis=dict(title='LE', range=[np.min(np.append(pred['le'], pred['lo'])), np.max(np.append(pred['le'], pred['hi']))]),
            xaxis=dict(title='Year', range=[np.min(pred.year), np.max(pred.year)]),
        title=dict_countries[country_selector] + ' Observed vs Predicted LE (' + dict_sex_inv[sex_selector] + ')',
        showlegend = False)

    return go.Figure(data=data, layout=layout)

@app.callback(
    dash.dependencies.Output('density_shifts', 'figure'),
    [dash.dependencies.Input('country_selector','value'),
     dash.dependencies.Input('year_selector','value'),
     dash.dependencies.Input('sex_selector','value')])

def update_density_shifts(country_selector, year_selector,
                            sex_selector):

    x1 = df.loc[(df.ctry==country_selector) & (df.year==year_selector) & (df.segment=='<1950'), 'pred_shift'].values
    x2 = df.loc[(df.ctry==country_selector) & (df.year==year_selector) & (df.segment=='1950-1969') , 'pred_shift']
    x3 = df.loc[(df.ctry==country_selector) & (df.year==year_selector) & (df.segment=='1970-1989') & (df.sex==sex_selector), 'pred_shift']
    x4 = df.loc[(df.ctry==country_selector) & (df.year==year_selector) & (df.segment=='>=1990') & (df.sex==sex_selector), 'pred_shift']

    hist_data = [x1,x2,x3,x4]
    fig = ff.create_distplot(hist_data,
                             group_labels=group_labels,
                             curve_type='kde',
                             show_hist=False,
                             show_rug=False,
                             colors=colors)

    fig['layout'].update(legend=dict(orientation='h', x=0.1, y=1.15, traceorder='normal'))
    fig['layout'].update(xaxis=dict(range=[np.concatenate(hist_data).min()-1, np.concatenate(hist_data).max()+1], title='\nDifference in years' ))
    # fig['layout'].update(yaxis=dict(range=[0,1]))
    fig['layout'].update(title=dict_countries[country_selector] + ' Shift for Year ' + str(year_selector) + ' by Year Segment (' + dict_sex_inv[sex_selector] + ')')

    return fig

# css
external_css = ["https://cdnjs.cloudflare.com/ajax/libs/skeleton/2.0.4/skeleton.min.css",
                "//fonts.googleapis.com/css?family=Raleway:400,300,600",
                "//fonts.googleapis.com/css?family=Dosis:Medium"]


for css in external_css:
    app.css.append_css({"external_url": css})


if __name__ == '__main__':
    app.run_server(debug=True)
