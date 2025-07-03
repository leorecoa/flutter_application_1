import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';
import { Trend } from 'k6/metrics';

// Métricas personalizadas
const errorRate = new Rate('errors');
const authLatency = new Trend('auth_latency');
const appointmentLatency = new Trend('appointment_latency');
const serviceLatency = new Trend('service_latency');

// Configuração do teste
export const options = {
  stages: [
    { duration: '1m', target: 50 },   // Rampa de subida para 50 usuários em 1 minuto
    { duration: '3m', target: 50 },   // Manter 50 usuários por 3 minutos
    { duration: '1m', target: 100 },  // Rampa de subida para 100 usuários em 1 minuto
    { duration: '5m', target: 100 },  // Manter 100 usuários por 5 minutos
    { duration: '1m', target: 0 },    // Rampa de descida para 0 usuários em 1 minuto
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% das requisições devem completar em menos de 500ms
    'http_req_duration{name:login}': ['p(95)<300'], // 95% dos logins devem completar em menos de 300ms
    'http_req_duration{name:get_appointments}': ['p(95)<400'], // 95% das consultas de agendamentos devem completar em menos de 400ms
    'http_req_duration{name:get_services}': ['p(95)<300'], // 95% das consultas de serviços devem completar em menos de 300ms
    errors: ['rate<0.1'], // Taxa de erro deve ser menor que 10%
  },
};

// Variáveis globais
const BASE_URL = 'https://api-dev.agendafacil.com/dev';
const USERS = JSON.parse(open('./test-users.json'));

// Função principal
export default function() {
  const user = USERS[Math.floor(Math.random() * USERS.length)];
  
  // Login
  const loginStart = new Date();
  const loginRes = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
    email: user.email,
    password: user.password,
  }), {
    headers: { 'Content-Type': 'application/json' },
    tags: { name: 'login' },
  });
  
  authLatency.add(new Date() - loginStart);
  
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
  
  // Obter agendamentos
  const appointmentStart = new Date();
  const appointmentsRes = http.get(`${BASE_URL}/appointments`, {
    headers: headers,
    tags: { name: 'get_appointments' },
  });
  
  appointmentLatency.add(new Date() - appointmentStart);
  
  check(appointmentsRes, {
    'appointments status is 200': (r) => r.status === 200,
    'appointments data is array': (r) => Array.isArray(r.json()),
  });
  
  // Obter serviços
  const serviceStart = new Date();
  const servicesRes = http.get(`${BASE_URL}/services`, {
    headers: headers,
    tags: { name: 'get_services' },
  });
  
  serviceLatency.add(new Date() - serviceStart);
  
  check(servicesRes, {
    'services status is 200': (r) => r.status === 200,
    'services data is array': (r) => Array.isArray(r.json()),
  });
  
  // Pausa entre iterações
  sleep(Math.random() * 3 + 1); // 1-4 segundos
}