set PRODUCERS;
set PRODUCTS;
set WAREHOUSES;
set STORES := 1..10;
set WEEKS := 1..52;

param yearly_production {PRODUCERS, PRODUCTS} >= 0;
param capacity {WAREHOUSES} >= 0;

param weekly_sales {WEEKS, STORES, PRODUCTS} >= 0;
param stockroom_capacity {STORES} >= 0;
# zapas = 10% średniej sprzedaży w tygodniu

param distance_prod_wh {PRODUCERS, WAREHOUSES} >= 0;
param distance_wh_store {WAREHOUSES, STORES} >= 0;
param transport_cost := 7; # zł/tona na km


var transport_prod_wh {PRODUCERS, WAREHOUSES, PRODUCTS} >= 0;
var transport_wh_store {WAREHOUSES, STORES, WEEKS, PRODUCTS} >= 0;
var stockroom_state {WEEKS, STORES, PRODUCTS} >= 0;

minimize all_transport_cost:
    ((sum {p in PRODUCERS, w in WAREHOUSES, ps in PRODUCTS} 
    	distance_prod_wh[p,w] * transport_prod_wh[p,w,ps])
    +
    (sum {w in WAREHOUSES, s in STORES, ws in WEEKS, ps in PRODUCTS} 
    	distance_wh_store[w,s] * transport_wh_store[w,s,ws,ps]))
    	* transport_cost;


# W magazynie sklepowym musi być tyle towaru co zapotrzebowanie + zapas
s.t. subj_weekly_sales{ws in WEEKS, s in STORES, ps in PRODUCTS}:
	stockroom_state[ws,s,ps] >= 1.1 * weekly_sales[ws,s,ps];

# Magazyn przysklepowy nie może być przepełniony
s.t. subj_store_stockroom_capacity{ws in WEEKS, s in STORES}:
	sum{ps in PRODUCTS} stockroom_state[ws,s,ps] <= stockroom_capacity[s];

# Magazyn nie jest przepełniony
s.t. subj_warehouse_capacity {w in WAREHOUSES}:
	sum {p in PRODUCERS, ps in PRODUCTS} transport_prod_wh[p,w,ps] <= capacity[w];

# Zapas sklpeu uwzględnia nadwyżki z poprzedniego tygodnia i dostawy
s.t. subj_shop_storage_includes_leftovers {ws in WEEKS, s in STORES, ps in PRODUCTS: ws > 1}:
    stockroom_state[ws,s,ps] = stockroom_state[ws-1,s,ps] - weekly_sales[ws-1,s,ps]
                          + sum {w in WAREHOUSES} transport_wh_store[w,s,ws,ps];

# Pierwszy tydzień - tylko dostawa, brak zapasów
s.t. subj_shop_storage_first_week {s in STORES, ps in PRODUCTS}:
    stockroom_state[1,s,ps] = sum {w in WAREHOUSES} transport_wh_store[w,s,1,ps];

# Magazyn nie może wysłać więcej niż ma na stanie
s.t. subj_trnasport_from_warehouses {w in WAREHOUSES, ps in PRODUCTS}:
	sum {ws in WEEKS, s in STORES} transport_wh_store[w,s,ws,ps] <= sum {p in PRODUCERS} transport_prod_wh[p,w,ps];
	
# Producent nie może wysłać więcej niż produkuje
s.t. subj_transport_from_producers {p in PRODUCERS, ps in PRODUCTS}:
	sum {w in WAREHOUSES} transport_prod_wh[p,w,ps] <= yearly_production[p,ps]

