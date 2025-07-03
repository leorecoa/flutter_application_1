const AWS = require('aws-sdk');
const cloudwatch = new AWS.CloudWatch();

/**
 * Publica métricas personalizadas no CloudWatch
 * @param {string} metricName - Nome da métrica
 * @param {number} value - Valor da métrica
 * @param {string} unit - Unidade da métrica (Count, Milliseconds, Bytes, etc.)
 * @param {Object} dimensions - Dimensões da métrica (chave-valor)
 * @returns {Promise} - Promessa da operação de publicação
 */
const publishMetric = async (metricName, value, unit = 'Count', dimensions = {}) => {
  const dimensionsArray = Object.entries(dimensions).map(([name, value]) => ({
    Name: name,
    Value: value
  }));
  
  const params = {
    MetricData: [
      {
        MetricName: metricName,
        Dimensions: dimensionsArray,
        Unit: unit,
        Value: value,
        Timestamp: new Date()
      }
    ],
    Namespace: 'AgendaFacil'
  };
  
  try {
    await cloudwatch.putMetricData(params).promise();
    console.log(`Metric published: ${metricName} = ${value} ${unit}`);
    return true;
  } catch (error) {
    console.error(`Error publishing metric ${metricName}:`, error);
    return false;
  }
};

/**
 * Registra métricas de negócio
 * @param {string} tenantId - ID do tenant
 * @param {string} metricName - Nome da métrica
 * @param {number} value - Valor da métrica
 * @param {string} unit - Unidade da métrica
 * @returns {Promise} - Promessa da operação de publicação
 */
const recordBusinessMetric = async (tenantId, metricName, value, unit = 'Count') => {
  return publishMetric(metricName, value, unit, {
    TenantId: tenantId,
    Environment: process.env.ENVIRONMENT || 'dev'
  });
};

/**
 * Registra métricas de performance
 * @param {string} functionName - Nome da função
 * @param {string} operation - Nome da operação
 * @param {number} duration - Duração em milissegundos
 * @returns {Promise} - Promessa da operação de publicação
 */
const recordPerformanceMetric = async (functionName, operation, duration) => {
  return publishMetric('OperationDuration', duration, 'Milliseconds', {
    FunctionName: functionName,
    Operation: operation,
    Environment: process.env.ENVIRONMENT || 'dev'
  });
};

/**
 * Registra métricas de uso por tenant
 * @param {string} tenantId - ID do tenant
 * @param {string} resourceType - Tipo de recurso (Lambda, DynamoDB, etc.)
 * @param {string} operation - Nome da operação
 * @param {number} count - Contagem de uso
 * @returns {Promise} - Promessa da operação de publicação
 */
const recordTenantUsageMetric = async (tenantId, resourceType, operation, count = 1) => {
  return publishMetric('TenantUsage', count, 'Count', {
    TenantId: tenantId,
    ResourceType: resourceType,
    Operation: operation,
    Environment: process.env.ENVIRONMENT || 'dev'
  });
};

/**
 * Registra métricas de erro
 * @param {string} functionName - Nome da função
 * @param {string} errorType - Tipo de erro
 * @param {number} count - Contagem de erros
 * @returns {Promise} - Promessa da operação de publicação
 */
const recordErrorMetric = async (functionName, errorType, count = 1) => {
  return publishMetric('ErrorCount', count, 'Count', {
    FunctionName: functionName,
    ErrorType: errorType,
    Environment: process.env.ENVIRONMENT || 'dev'
  });
};

/**
 * Registra métricas de uso por plano
 * @param {string} plan - Plano (free, pro, enterprise)
 * @param {string} feature - Recurso utilizado
 * @param {number} count - Contagem de uso
 * @returns {Promise} - Promessa da operação de publicação
 */
const recordPlanUsageMetric = async (plan, feature, count = 1) => {
  return publishMetric('PlanUsage', count, 'Count', {
    Plan: plan,
    Feature: feature,
    Environment: process.env.ENVIRONMENT || 'dev'
  });
};

module.exports = {
  publishMetric,
  recordBusinessMetric,
  recordPerformanceMetric,
  recordTenantUsageMetric,
  recordErrorMetric,
  recordPlanUsageMetric
};