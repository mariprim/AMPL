
set t;


param P_R = 1500;  # Potência da resistência de aquecimento (kW)

# Temperatura ambiente em torno do EWH no tempo t (°C)
param tau_amb{i in t};


param tau_0 = 55;  # Temperatura em t0 (°C)

param tau_net = 18;  # Temperatura de entrada da água (°C)

# Retirada de água para consumo no tempo t (kg)
param m{i in t};

param M = 100;  # Capacidade do tanque de água quente (kg)

param AU = 2.06;  # �rea da envolvente do depósito (m²) vezes coeficiente de transferência de calor do depósito (W/m².°C)

param Cp = 1.14194008;  # Calor específico da água (J/kg.°C)

param tau_min = 45;  # Temperatura mínima (°C)

param tau_max = 85;  # Temperatura máxima permitida (°C)

param t_req = 11;  # Tempo necessário para manter uma determinada temperatura para eliminar as bactérias (min)

param tau_req = 60;  # Temperatura especificada a ser mantida para que t_req elimine as bactérias (°C)

param tau_min_comf=50;
param tau_max_comf=80;

param tau_t_dev{i in t} = 0;


param peso = 0.1;

var v_t{i in t} binary;  # Variável binária que define o controle on/off do elemento de aquecimento no tempo t
var tau_t{i in t} >= 0;  # Temperatura da água quente no interior do tanque no tempo t (°C)
var n_t{i in t} binary;  # Variável binária igual a 1 no primeiro t em que tau_t > tau_req para t_req
var P_t_losses{i in t} >= 0;  # Perdas de potência através da envolvente no tempo t (kW)

minimize Cost: sum{i in t} P_R * v_t[i];  # Função objetivo de custo

minimize Discomfort: sum{i in t} tau_t[i];  # Função objetivo de desconforto

subject to Losses_Constraint{i in t}: P_t_losses[i] = AU * (tau_t[i] - tau_amb[i]);

subject to Temperature_Constraint{i in t}: tau_t[i] = ((M - m[i])/M * tau_t[i] + m[i]/M * tau_net + P_R * v_t[i] - P_t_losses[i]) / (M * Cp);

subject to Min_Temperature_Constraint{i in t}: tau_t[i] >= tau_min - M * v_t[i];

subject to Max_Temperature_Constraint{i in t}: tau_t[i] >= tau_max + M * (1 - v_t[i]);

#subject to Legionella_Constraint: sum{i in t} n_t[i] = 1;

subject to Temperature_Req_Constraint{i in t}: tau_t[i] >= tau_req * n_t[i];


subject to Nonnegative_Constraints{i in t}: P_t_losses[i] >= 0;

# Restrições para minimizar o desconforto
subject to Deviation_Constraint1{i in t}: tau_t[i] + tau_t[i] >= 2 * tau_min - tau_min_comf;
subject to Deviation_Constraint2{i in t}: tau_t[i] + tau_t[i] <= 2 * tau_max - tau_max_comf;
subject to Nonnegative_Constraints_comf{i in t}: tau_t_dev[i] >= 0;
