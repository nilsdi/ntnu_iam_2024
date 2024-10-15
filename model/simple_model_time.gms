Sets
        technology / coal_ppl, gas_ppl, wind_ppl /
        year / 2020, 2030/
*        vintage(year)
        ;
*vintage(year) = YES;
ALIAS(year, vintage);
Variables
        ACT(technology, year) technology activity
        CAP_NEW(technology, year) new technology capacity
        EMISS_ANNUAL (year) emissions per year
        TOTAL_EMISS total emissions across all time steps
        COST_ANNUAL (year) operating cost 
        TOTAL_COST total energy system cost
        ;
Parameter
        demand (year) total energy demand per hour in MWh / 2020 100, 2030 120 /
        ;
TABLE
        inv(technology, year) '$/[kw]'
                        2020    2030 
        coal_ppl        1500    1500
        gas_ppl         800     800
        wind_ppl        1000    1000
;
TABLE
        fom(technology, year)
                        2020    2030
        coal_ppl        60      60
        gas_ppl         32      32
        wind_ppl        40      40
;
TABLE
        vom(technology, year) '[$/MWh]'
                        2020    2030
        coal_ppl        0.018   0.018
        gas_ppl         0.036   0.036
        wind_ppl        0       0
;
TABLE
        emission_intensity(technology, year) '[g/kWh]'
                        2020    2030
        coal_ppl        846     846
        gas_ppl         366     366
        wind_ppl        0       0
;
TABLE
        hours(technology, year)
                        2020    2030
        coal_ppl        7000    7000
        gas_ppl         7000    7000
        wind_ppl        2000    2000
;
Equations
        EQ_COST
        EQ_COST_ANNUAL(year)
        EQ_ENERGY_BALANCE(year)
        EQ_EMISS_ANNUAL(year)
        EQ_TOTAL_EMISSION
        EQ_CAPACITY_BALANCE
        ;

EQ_COST_ANNUAL(year)..   Sum(technology, ACT(technology, year)*vom(technology, year)
                                        + CAP_NEW(technology, year) * inv(technology,year)
                                        + Sum(vintage $ (ORD(vintage)le ORD(year)), CAP_NEW(technology, vintage)*fom(technology, vintage) )
                                        - )
                        =E= COST_ANNUAL(year);
EQ_COST..   Sum(year, COST_ANNUAL(year)) =E= TOTAL_COST;
EQ_ENERGY_BALANCE(year).. SUM(technology, ACT(technology, year)) =G= demand(year);
EQ_EMISS_ANNUAL(year).. Sum(technology, ACT(technology, year)*emission_intensity(technology, year)) =E= EMISS_ANNUAL(year);
EQ_TOTAL_EMISSION.. Sum(year, EMISS_ANNUAL(year)) =E= TOTAL_EMISS;
EQ_CAPACITY_BALANCE(technology, year).. ACT(technology, year) =L= Sum(vintage $ (ORD(vintage)le ORD(year)), CAP_NEW(technology, vintage)* hours(technology, year));

Model simple_model / all / ;
ACT.LO(technology, year) = 0;
CAP_NEW.LO(technology, vintage) = 0;
*TOTAL_EMISS.UP = 200;
*TOTAL_COST.UP = 5050;

Solve simple_model minimize TOTAL_COST using LP;