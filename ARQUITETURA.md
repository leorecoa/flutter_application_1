# 🏗️ ARQUITETURA AGENDAFÁCIL SAAS

## 📊 **DIAGRAMA DE ARQUITETURA COMPLETA**

```
                    🌍 INTERNET
                         │
                ┌────────▼────────┐
                │   Route53 DNS   │
                │  agendafacil.com │
                └────────┬────────┘
                         │
                ┌────────▼────────┐
                │   CloudFront    │
                │   CDN Global    │
                └────────┬────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   ┌────▼────┐    ┌─────▼─────┐    ┌────▼────┐
   │   S3    │    │    API    │    │ Static  │
   │ Files   │    │ Gateway   │    │ Assets  │
   └─────────┘    └─────┬─────┘    └─────────┘
                        │
                ┌───────▼───────┐
                │   Cognito     │
                │ Authorizer    │
                └───────┬───────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
   ┌────▼────┐    ┌────▼────┐    ┌────▼────┐
   │ Lambda  │    │ Lambda  │    │ Lambda  │
   │  Auth   │    │ Tenant  │    │Services │
   └────┬────┘    └────┬────┘    └────┬────┘
        │              │              │
        └──────────────┼──────────────┘
                       │
                ┌──────▼──────┐
                │  DynamoDB   │
                │Single Table │
                │ Multi-Tenant│
                └─────────────┘
```

## 🔄 **FLUXO DE DADOS MULTI-TENANT**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Tenant A  │    │   Tenant B  │    │   Tenant C  │
│   (Salon)   │    │ (Barbershop)│    │   (Spa)     │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │
       └──────────────────┼──────────────────┘
                          │
                    ┌─────▼─────┐
                    │    JWT    │
                    │ tenantId  │
                    │   plan    │
                    └─────┬─────┘
                          │
                    ┌─────▼─────┐
                    │Middleware │
                    │Multi-Tenant│
                    └─────┬─────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
   ┌────▼────┐       ┌───▼───┐       ┌────▼────┐
   │TENANT#A │       │TENANT#B│       │TENANT#C │
   │#SERVICES│       │#USERS │       │#APPTS   │
   └─────────┘       └───────┘       └─────────┘
```

## 🏢 **ESTRUTURA MULTI-TENANT DYNAMODB**

```
┌─────────────────────────────────────────────────────────┐
│                    MAIN TABLE                           │
├─────────────────────────────────────────────────────────┤
│ PK                    │ SK              │ Data          │
├─────────────────────────────────────────────────────────┤
│ TENANT#uuid-a         │ CONFIG          │ {name, theme} │
│ TENANT#uuid-a         │ USER#user-1     │ {role: admin} │
│ TENANT#uuid-a#SERVICES│ SERVICE#svc-1   │ {name, price} │
│ TENANT#uuid-a#APPTS   │ APPOINTMENT#1   │ {date, client}│
├─────────────────────────────────────────────────────────┤
│ TENANT#uuid-b         │ CONFIG          │ {name, theme} │
│ TENANT#uuid-b         │ USER#user-2     │ {role: user}  │
│ TENANT#uuid-b#SERVICES│ SERVICE#svc-2   │ {name, price} │
└─────────────────────────────────────────────────────────┘
```

## 🔐 **FLUXO DE AUTENTICAÇÃO**

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ Flutter │───▶│ Cognito │───▶│   JWT   │───▶│ Lambda  │
│  Login  │    │  Auth   │    │ + Claims│    │Function │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
                                   │              │
                                   ▼              ▼
                            ┌─────────────┐ ┌─────────────┐
                            │ tenantId    │ │ Middleware  │
                            │ plan: pro   │ │ Validation  │
                            │ groups: []  │ │ & Isolation │
                            └─────────────┘ └─────────────┘
```

## 📊 **SISTEMA DE RELATÓRIOS**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Services   │    │  Clients    │    │ Financial   │
│  Report     │    │  Report     │    │  Report     │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │
       └──────────────────┼──────────────────┘
                          │
                    ┌─────▼─────┐
                    │ Relatorio │
                    │ Function  │
                    └─────┬─────┘
                          │
                    ┌─────▼─────┐
                    │    CSV    │
                    │ Generator │
                    └─────┬─────┘
                          │
                    ┌─────▼─────┐
                    │ S3 Upload │
                    │ + Signed  │
                    │   URL     │
                    └───────────┘
```

## 🎯 **COMPONENTES POR CAMADA**

### **Apresentação (Frontend)**
```
Flutter Web App
├── Auth Module (Login/Register)
├── Dashboard Module (KPIs/Stats)
├── Services Module (CRUD)
├── Appointments Module (Calendar)
├── Clients Module (Management)
├── Booking Module (Public)
└── Settings Module (Tenant Config)
```

### **API Layer**
```
API Gateway
├── /auth/* (Public)
├── /tenants/* (Authenticated)
├── /services/* (Authenticated)
├── /appointments/* (Authenticated)
├── /users/* (Authenticated)
├── /booking/* (Public)
├── /relatorios/* (Authenticated)
└── /admin/* (Super Admin)
```

### **Business Logic (Lambda)**
```
Lambda Functions
├── AuthFunction (Cognito Integration)
├── TenantFunction (Multi-tenant Management)
├── ServicesFunction (CRUD Operations)
├── AppointmentsFunction (Scheduling)
├── UsersFunction (User Management)
├── BookingFunction (Public Booking)
├── RelatorioFunction (Reports & Export)
└── AdminFunction (Super Admin Panel)
```

### **Data Layer**
```
DynamoDB Single Table
├── Tenant Configs
├── User-Tenant Associations
├── Services per Tenant
├── Appointments per Tenant
└── GSI for Queries

S3 Bucket
├── Tenant Logos
├── Generated Reports
└── Static Assets
```

### **Observability**
```
CloudWatch
├── Lambda Metrics (Invocations, Errors, Duration)
├── API Gateway Metrics (4xx, 5xx, Latency)
├── DynamoDB Metrics (Capacity, Throttles)
├── Custom Business Metrics
└── Structured Logs (JSON)

X-Ray
├── Distributed Tracing
├── Service Map
└── Performance Analysis
```

## 🚀 **DEPLOYMENT PIPELINE**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   GitHub    │───▶│   Actions   │───▶│     AWS     │
│ Repository  │    │   CI/CD     │    │ Environment │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Code Push   │    │ Test + Lint │    │ SAM Deploy  │
│ develop/main│    │ + Security  │    │ + Health    │
└─────────────┘    └─────────────┘    └─────────────┘
```

## 💰 **COST OPTIMIZATION**

```
┌─────────────────────────────────────────────────────────┐
│                 COST BREAKDOWN                          │
├─────────────────────────────────────────────────────────┤
│ Service         │ Usage          │ Cost/Month          │
├─────────────────────────────────────────────────────────┤
│ Lambda          │ 1M invocations │ $50                 │
│ DynamoDB        │ Auto-scaling   │ $25                 │
│ API Gateway     │ 1M requests    │ $35                 │
│ S3              │ 100GB storage  │ $5                  │
│ CloudFront      │ Global CDN     │ $10                 │
│ Cognito         │ 1000 MAU       │ $15                 │
├─────────────────────────────────────────────────────────┤
│ TOTAL           │ 1000 tenants   │ $140/month          │
│ REVENUE         │ $50/tenant     │ $50,000/month       │
│ PROFIT MARGIN   │ 99.7%          │ $49,860/month       │
└─────────────────────────────────────────────────────────┘
```

## 🔄 **SCALING STRATEGY**

### **Horizontal Scaling**
- Lambda: Auto-scaling por demanda
- DynamoDB: Auto-scaling 5-1000 RCU/WCU
- API Gateway: Rate limiting por tenant
- CloudFront: CDN global automático

### **Vertical Scaling**
- Lambda Memory: 256MB (dev) → 1024MB (prod)
- DynamoDB: Provisioned → On-Demand (high traffic)
- Provisioned Concurrency: Endpoints críticos

### **Geographic Scaling**
- Multi-region deployment (preparado)
- CloudFront edge locations globais
- DynamoDB Global Tables (futuro)

---

**Esta arquitetura suporta crescimento de 0 a 1M+ tenants com alta disponibilidade, segurança enterprise e custos otimizados.**