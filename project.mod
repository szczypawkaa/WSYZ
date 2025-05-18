set PRODUCERS;
set PRODUCTS;
set WAREHOUSES;
set STORES;
set WEEKS;

param yearly_production {PRODUCERS, PRODUCTS} >= 0;
param capacity {WAREHOUSES} >= 0;

param weekly_sales {WEEKS, STORES, PRODUCTS} >= 0;
param stockroom_capacity {STORES} >= 0;

param distance_prod_wh {PRODUCERS, WAREHOUSES} >= 0;
param distance_wh_store {WAREHOUSES, STORES} >= 0;
param transport_cost := 7; # zł/tona na km

var transport_prod_wh {PRODUCERS, WAREHOUSES, PRODUCTS} >= 0;
var transport_wh_store {WAREHOUSES, STORES, WEEKS, PRODUCTS} >= 0;


minimize all_transport_cost:
    sum {p in PRODUCERS, w in WAREHOUSES, ps in PRODUCTS} transport_prod_wh[p,w,ps] +
    sum {w in WAREHOUSES, s in STORES, ws in WEEKS, ps in PRODUCTS} transport_wh_store[w,s,ws,ps];


s.t. subj_weekly_sales{ws in WEEKS, s in STORES, ps in PRODUCTS}:
	sum {w in WAREHOUSES} transport_wh_store[w,s,ws,ps] = weekly_sales[ws,s,ps];