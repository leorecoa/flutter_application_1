import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Métricas personalizadas
const errorRate = new Rate('errors');

// Configuração do teste de estresse
export const options = {
  stages: [
    { duration: '2m', target: 100 },   // Rampa de subida para 100 usuários em 2 minutos
    { duration: '5m', target: 100 },   // Manter 100 usuários por 5 minutos
    { duration: '2m', target: 200 },   // Rampa de subida para 200 usuários em 2 minutos
    { duration: '5m', target: 200 },   // Manter 200 usuários por 5 minutos
    { duration: '2m', target: 300 },   // Rampa de subida para 300 usuários em 2 minutos
    { duration: '5m', target: 300 },   // Manter 300 usuários por 5 minutos
    { duration: '2m', target: 0 },     // Rampa de descida para 0 usuários em 2 minutos
  ],
  thresholds: {
    http_req_duration: ['p(95)<1000'], // 95% das requisições devem completar em menos de 1s
    http_req_failed: ['rate<0.2'],     // Taxa de falha deve ser menor que 20%
    errors: ['rate<0.2'],              // Taxa de erro deve ser menor que 20%
  },
};

// Variáveis globais
const BASE_URL = 'https://api-dev.agendafacil.com/dev';
const USERS = JSON.parse(open('./test-users.json'));

// Função principal
export default function() {
  const user = USERS[Math.floor(Math.random() * USERS.length)];
  
  // Login
  const loginRes = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
    email: user.email,
    password: user.password,
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  const success = check(loginRes, {
    'login status is 200': (r) => r.status === 200,
    'has access token': (r) => r.json('token') !== undefined,
  });
  
  if (!success) {
    errorRate.add(1);
    sleep(1);
    return;
  }
  
  const token = loginRes.json('token');
  const headers = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  };
  
  // Operações intensivas
  
  // 1. Busca de agendamentos com filtros
  http.get(`${BASE_URL}/appointments?startDate=2023-01-01&endDate=2023-12-31&status=confirmed`, {
    headers: headers,
  });
  
  // 2. Busca de clientes com paginação
  http.get(`${BASE_URL}/clients?page=1&limit=50&sort=name`, {
    headers: headers,
  });
  
  // 3. Geração de relatório
  http.post(`${BASE_URL}/relatorios/financeiro`, JSON.stringify({
    startDate: '2023-01-01',
    endDate: '2023-12-31',
    groupBy: 'day',
  }), {
    headers: headers,
  });
  
  // 4. Criação de agendamento
  http.post(`${BASE_URL}/appointments`, JSON.stringify({
    clientId: 'client-123',
    serviceId: 'service-456',
    date: '2023-08-15T14:00:00Z',
    duration: 60,
    notes: 'Teste de estresse',
  }), {
    headers: headers,
  });
  
  // 5. Busca de disponibilidade
  http.get(`${BASE_URL}/availability?date=2023-08-15&serviceId=service-456`, {
    headers: headers,
  });
  
  // Pausa curta entre iterações
  sleep(Math.random() * 2 + 0.5); // 0.5-2.5 segundos
}