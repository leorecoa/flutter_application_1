import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Métricas personalizadas
const errorRate = new Rate('errors');

// Configuração do teste de pico (spike)
export const options = {
  stages: [
    { duration: '1m', target: 10 },    // Iniciar com 10 usuários
    { duration: '1m', target: 10 },    // Manter 10 usuários por 1 minuto
    { duration: '30s', target: 500 },  // Pico rápido para 500 usuários em 30 segundos
    { duration: '2m', target: 500 },   // Manter 500 usuários por 2 minutos
    { duration: '30s', target: 10 },   // Reduzir para 10 usuários em 30 segundos
    { duration: '1m', target: 10 },    // Manter 10 usuários por 1 minuto
    { duration: '30s', target: 500 },  // Segundo pico para 500 usuários em 30 segundos
    { duration: '2m', target: 500 },   // Manter 500 usuários por 2 minutos
    { duration: '1m', target: 0 },     // Reduzir para 0 usuários em 1 minuto
  ],
  thresholds: {
    http_req_duration: ['p(99)<3000'], // 99% das requisições devem completar em menos de 3s
    http_req_failed: ['rate<0.3'],     // Taxa de falha deve ser menor que 30%
    errors: ['rate<0.3'],              // Taxa de erro deve ser menor que 30%
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
    sleep(0.5);
    return;
  }
  
  const token = loginRes.json('token');
  const headers = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  };
  
  // Simular cenário de pico - múltiplas requisições simultâneas
  
  // Batch de requisições para simular carga alta
  const requests = [
    {
      method: 'GET',
      url: `${BASE_URL}/appointments`,
      params: { headers: headers }
    },
    {
      method: 'GET',
      url: `${BASE_URL}/clients`,
      params: { headers: headers }
    },
    {
      method: 'GET',
      url: `${BASE_URL}/services`,
      params: { headers: headers }
    },
    {
      method: 'GET',
      url: `${BASE_URL}/dashboard/stats`,
      params: { headers: headers }
    },
    {
      method: 'POST',
      url: `${BASE_URL}/relatorios/export`,
      body: JSON.stringify({
        reportType: 'financeiro',
        format: 'csv',
        params: {
          startDate: '2023-01-01',
          endDate: '2023-12-31'
        }
      }),
      params: { headers: headers }
    }
  ];
  
  // Enviar todas as requisições em paralelo
  const responses = http.batch(requests);
  
  // Verificar respostas
  for (let i = 0; i < responses.length; i++) {
    check(responses[i], {
      [`request ${i} status is 200 or 201`]: (r) => r.status === 200 || r.status === 201,
    });
  }
  
  // Pausa muito curta entre iterações para maximizar o pico
  sleep(Math.random() * 0.5 + 0.1); // 0.1-0.6 segundos
}