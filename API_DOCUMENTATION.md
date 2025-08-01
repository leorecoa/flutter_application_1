# API Documentation - AGENDEMAIS

## Overview

This document describes the API endpoints and data models used by the AGENDEMAIS application. The API follows RESTful principles and uses JSON for data exchange.

## Base URL

```
https://api.agendemais.com/v1
```

## Authentication

All API requests require authentication using JWT tokens. Include the token in the Authorization header:

```
Authorization: Bearer <token>
```

## Endpoints

### Authentication

#### POST /auth/login

Authenticates a user and returns a JWT token.

**Request:**
```json
{
  "username": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "user123",
      "name": "John Doe",
      "email": "user@example.com"
    }
  }
}
```

#### POST /auth/register

Registers a new user.

**Request:**
```json
{
  "name": "John Doe",
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user123",
    "name": "John Doe",
    "email": "user@example.com"
  }
}
```

### Appointments

#### GET /appointments

Returns a list of appointments.

**Query Parameters:**
- `status` (optional): Filter by status (scheduled, confirmed, completed, cancelled)
- `startDate` (optional): Filter by start date (ISO format)
- `endDate` (optional): Filter by end date (ISO format)
- `searchTerm` (optional): Search by client name or service

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "appt123",
      "professionalId": "prof123",
      "serviceId": "serv123",
      "dateTime": "2023-07-15T10:30:00Z",
      "clientName": "Jane Smith",
      "clientPhone": "123456789",
      "service": "Haircut",
      "price": 50.0,
      "status": "scheduled",
      "confirmedByClient": false,
      "createdAt": "2023-07-10T15:30:00Z",
      "updatedAt": "2023-07-10T15:30:00Z"
    }
  ]
}
```

#### GET /appointments/paginated

Returns a paginated list of appointments.

**Query Parameters:**
- `page` (required): Page number (starts at 1)
- `pageSize` (required): Number of items per page
- `status` (optional): Filter by status
- `startDate` (optional): Filter by start date
- `endDate` (optional): Filter by end date
- `searchTerm` (optional): Search by client name or service

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "appt123",
      "professionalId": "prof123",
      "serviceId": "serv123",
      "dateTime": "2023-07-15T10:30:00Z",
      "clientName": "Jane Smith",
      "clientPhone": "123456789",
      "service": "Haircut",
      "price": 50.0,
      "status": "scheduled",
      "confirmedByClient": false,
      "createdAt": "2023-07-10T15:30:00Z",
      "updatedAt": "2023-07-10T15:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalItems": 45,
    "totalPages": 3
  }
}
```

#### POST /appointments

Creates a new appointment.

**Request:**
```json
{
  "professionalId": "prof123",
  "serviceId": "serv123",
  "dateTime": "2023-07-15T10:30:00Z",
  "clientName": "Jane Smith",
  "clientPhone": "123456789",
  "service": "Haircut",
  "price": 50.0
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "appt123",
    "professionalId": "prof123",
    "serviceId": "serv123",
    "dateTime": "2023-07-15T10:30:00Z",
    "clientName": "Jane Smith",
    "clientPhone": "123456789",
    "service": "Haircut",
    "price": 50.0,
    "status": "scheduled",
    "confirmedByClient": false,
    "createdAt": "2023-07-10T15:30:00Z",
    "updatedAt": "2023-07-10T15:30:00Z"
  }
}
```

#### PUT /appointments/{id}

Updates an existing appointment.

**Request:**
```json
{
  "clientName": "Jane Smith",
  "clientPhone": "987654321",
  "service": "Haircut and Style",
  "price": 60.0
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "appt123",
    "professionalId": "prof123",
    "serviceId": "serv123",
    "dateTime": "2023-07-15T10:30:00Z",
    "clientName": "Jane Smith",
    "clientPhone": "987654321",
    "service": "Haircut and Style",
    "price": 60.0,
    "status": "scheduled",
    "confirmedByClient": false,
    "createdAt": "2023-07-10T15:30:00Z",
    "updatedAt": "2023-07-11T09:15:00Z"
  }
}
```

#### PUT /appointments/{id}/status

Updates the status of an appointment.

**Request:**
```json
{
  "status": "confirmed"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "appt123",
    "status": "confirmed",
    "updatedAt": "2023-07-11T09:20:00Z"
  }
}
```

#### DELETE /appointments/{id}

Deletes an appointment.

**Response:**
```json
{
  "success": true,
  "message": "Appointment deleted successfully"
}
```

#### POST /appointments/batch

Creates multiple appointments at once.

**Request:**
```json
{
  "appointments": [
    {
      "professionalId": "prof123",
      "serviceId": "serv123",
      "dateTime": "2023-07-15T10:30:00Z",
      "clientName": "Jane Smith",
      "clientPhone": "123456789",
      "service": "Haircut",
      "price": 50.0
    },
    {
      "professionalId": "prof123",
      "serviceId": "serv123",
      "dateTime": "2023-07-16T10:30:00Z",
      "clientName": "John Doe",
      "clientPhone": "987654321",
      "service": "Haircut",
      "price": 50.0
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "appt123",
      "professionalId": "prof123",
      "serviceId": "serv123",
      "dateTime": "2023-07-15T10:30:00Z",
      "clientName": "Jane Smith",
      "clientPhone": "123456789",
      "service": "Haircut",
      "price": 50.0,
      "status": "scheduled",
      "confirmedByClient": false,
      "createdAt": "2023-07-10T15:30:00Z",
      "updatedAt": "2023-07-10T15:30:00Z"
    },
    {
      "id": "appt124",
      "professionalId": "prof123",
      "serviceId": "serv123",
      "dateTime": "2023-07-16T10:30:00Z",
      "clientName": "John Doe",
      "clientPhone": "987654321",
      "service": "Haircut",
      "price": 50.0,
      "status": "scheduled",
      "confirmedByClient": false,
      "createdAt": "2023-07-10T15:30:00Z",
      "updatedAt": "2023-07-10T15:30:00Z"
    }
  ]
}
```

### Tenants

#### GET /tenants

Returns a list of tenants for the current user.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "tenant123",
      "name": "Salon A",
      "plan": "pro",
      "createdAt": "2023-01-15T10:30:00Z",
      "isActive": true,
      "settings": {
        "theme": "light",
        "notificationsEnabled": true
      }
    }
  ]
}
```

#### POST /tenants

Creates a new tenant.

**Request:**
```json
{
  "name": "Salon B",
  "plan": "basic"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "tenant124",
    "name": "Salon B",
    "plan": "basic",
    "createdAt": "2023-07-11T15:30:00Z",
    "isActive": true,
    "settings": {}
  }
}
```

## Error Handling

All endpoints return a consistent error format:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "clientName": "Name is required"
    }
  }
}
```

Common error codes:
- `VALIDATION_ERROR`: Invalid input data
- `NOT_FOUND`: Resource not found
- `UNAUTHORIZED`: Authentication required
- `FORBIDDEN`: Permission denied
- `INTERNAL_ERROR`: Server error

## Data Models

### Appointment

| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique identifier |
| professionalId | String | ID of the professional |
| serviceId | String | ID of the service |
| dateTime | DateTime | Date and time of the appointment |
| clientName | String | Name of the client |
| clientPhone | String | Phone number of the client |
| service | String | Name of the service |
| price | Double | Price of the service |
| status | String | Status of the appointment (scheduled, confirmed, completed, cancelled) |
| confirmedByClient | Boolean | Whether the client has confirmed the appointment |
| createdAt | DateTime | Creation timestamp |
| updatedAt | DateTime | Last update timestamp |

### Tenant

| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique identifier |
| name | String | Name of the tenant |
| plan | String | Subscription plan (basic, pro, enterprise) |
| createdAt | DateTime | Creation timestamp |
| isActive | Boolean | Whether the tenant is active |
| settings | Object | Tenant-specific settings |

## Versioning

The API uses URL versioning (v1, v2, etc.). The current version is v1.