import os.path
from sqlite3 import Cursor, OperationalError, connect
from flask import Flask, g, redirect, render_template, request
import sqlite3
from datetime import datetime

DATABASE='../hotel.db'

app = Flask(__name__,  template_folder='./html/')


@app.route('/admin/update/<id>', methods=['POST','GET'])
def update(id):
    ret = {}

    query = "select room_id from room where hotel=(select hotel from reservation where id={0})".format(id)
    data = query_db(query)
    if data:
        ret['rooms'] = [i['room_id'] for i in data]
    else:
        ret['rooms'] = []
    

    if request.method=='POST':
        room_id=request.form['room']
        employee_id=request.form['employee']
        print (room_id, employee_id)
        query = "update reservation set room_id={0}, reception_id={1} where id={2}".format(room_id, employee_id, id)
        try:
            print (query)
            query_db(query)
            
            return redirect('../')
        except sqlite3.IntegrityError:
            return 'error in your sql: '+query+'\n, check your employee id!'
            
    return render_template('updateResv.html', data=ret)

@app.route('/admin/delete/<id>', methods=['POST','GET'])
def delete(id):
    query = "delete from reservation where id={0}".format(id)
    print (query)
    query_db(query)
    return redirect('../')


@app.route('/admin/', methods=['POST','GET'])
def admin():
    ret = {}
    query = "select r.id, first_name, last_name, hotel, reception_id, checkin, checkout from reservation r, visitor v where v.id=r.visitor_id and r.room_id is NULL"
    waiting_data = query_db(query)
    ret['reservation'] = waiting_data
    query = "select r.id, first_name, last_name, hotel, reception_id, checkin, checkout from reservation r, visitor v where v.id=r.visitor_id and room_id is NOT NULL"
    roomed_data = query_db(query)
    ret['all'] = roomed_data
    ret['summary'] = query_db("select count(*) from reservation;", one=True)['count(*)']
    hotels = [i['name'] for i in query_db('select distinct name from hotel')]
    visitors = [i['id'] for i in query_db('select distinct id from visitor')]
    if request.method=='POST':
        fields = request.form['user_selection']
    else:
        fields='first_name, last_name'
    super_visitor = []
    for visitor in visitors:
        have_been = []
        for hotel in hotels:
            if_been = query_db("select id from reservation where visitor_id={0} and hotel='{1}'".format(visitor, hotel), one=True)
            print (visitor, hotel, if_been)
            if not if_been:
                break
            have_been.append(if_been)
        if len(have_been) == len(hotels):
            print ('super visitor !!', have_been)
            super_visitor.append(query_db("select "+fields+" from visitor where id="+str(visitor), one=True))
    ret['super_visitor'] = super_visitor

    return render_template('admin.html', data=ret)


@app.route('/guest/', methods=['POST','GET'])
def guest():
    ret = {}
    
    # get all hotels
    ret['hotels'] =[i['name'] for i in query_db('select distinct name from hotel')]
    ret['rooms'] =  query_db('select count(*) room_number, hotel from room group by hotel')
    print (ret['rooms'])
    # if user checking sth
    if request.method=='POST':
        data = request.form
        if 'id' in data.keys():
            print('checking reservation')
            if data['id']:
                
                query = "select id, room_id, hotel, reception_id, checkin, checkout from reservation where id="+str(data['id'])
                print (query)
                res = query_db(query, one=True)
                print (res)
                if res:
                    ret.update(res)
                    print (ret)
                else:
                    return 'no reservation found '
            else:
                return "please give me an ID"
        else:
            print('creating new reservation')
            query = "select id from visitor where last_name='{0}' and first_name='{1}' and phone='{2}' ".format(data['last_name'], data['first_name'], data['phone'])
            visitor_id = query_db(query, one=True)
            if not visitor_id:
                query = "select id from visitor order by id desc limit 1"
                visitor_id=query_db(query, one=True)['id']+1

                query = "insert into visitor (id, last_name, first_name, phone) VALUES ({0}, '{1}', '{2}', '{3}')".format(visitor_id, data['last_name'], data['first_name'], data['phone'])
                print (query)
                query_db(query)
            else:
                visitor_id = visitor_id['id']
            
            
            
            print ('create visitor', visitor_id)
            checkin, checkout = data['duration'].split(' - ')
            checkin = datetime.strptime(checkin, '%m/%d/%Y').date()
            checkout = datetime.strptime(checkout, '%m/%d/%Y').date()
            print(checkin)
            query = "select id from reservation order by id desc limit 1"
            reservation_id=query_db(query, one=True)['id']+1
            query = "insert into reservation (id, visitor_id, hotel, checkin, checkout) values ({0}, {1}, '{2}', '{3}', '{4}')".format(reservation_id, visitor_id, data['hotel'], checkin, checkout)
            print (query)
            query_db(query)

            
            print ('create reservation', reservation_id)
            ret['reservation_id'] = reservation_id

    return render_template('guest.html', data=ret)

@app.route('/')
# ‘/’ URL is bound with hello_world() function.
def main(): 
    get_db()
    return render_template('main.html')  

def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d


def get_db():
    if os.path.exists(DATABASE):
        db = sqlite3.connect(DATABASE)
    else:
        db = sqlite3.connect(DATABASE)
        with open('../create_table.sql','r') as f:
            db.executescript(f.read())
            db.commit()
    db.close()



def query_db(query, args=(), one=False):
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = dict_factory
    cur = conn.execute(query, args)
    rv = cur.fetchall()
    conn.commit()
    cur.close()
    return (rv[0] if rv else None) if one else rv

@app.teardown_appcontext
def close_connection(exception):
    db = getattr(g, '_database', None)
    if db is not None:
        db.close()

 
# main driver function
if __name__ == '__main__':
 
    # run() method of Flask class runs the application
    # on the local development server.

    app.run(debug=True)