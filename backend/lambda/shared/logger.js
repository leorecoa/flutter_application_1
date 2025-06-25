class StructuredLogger {
  constructor(context = {}) {
    this.context = {
      service: 'agenda-facil-backend',
      environment: process.env.ENVIRONMENT || 'dev',
      version: process.env.VERSION || '1.0.0',
      ...context
    };
  }

  _log(level, message, data = {}, error = null) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level: level.toUpperCase(),
      message,
      ...this.context,
      ...data
    };

    if (error) {
      logEntry.error = {
        name: error.name,
        message: error.message,
        stack: error.stack,
        code: error.code
      };
    }

    // Add correlation ID if available
    if (this.correlationId) {
      logEntry.correlationId = this.correlationId;
    }

    // Add tenant context if available
    if (this.tenantId) {
      logEntry.tenantId = this.tenantId;
    }

    if (this.userId) {
      logEntry.userId = this.userId;
    }

    console.log(JSON.stringify(logEntry));
  }

  setCorrelationId(id) {
    this.correlationId = id;
    return this;
  }

  setTenantContext(tenantId, userId) {
    this.tenantId = tenantId;
    this.userId = userId;
    return this;
  }

  setContext(context) {
    this.context = { ...this.context, ...context };
    return this;
  }

  info(message, data = {}) {
    this._log('info', message, data);
  }

  warn(message, data = {}) {
    this._log('warn', message, data);
  }

  error(message, data = {}, error = null) {
    this._log('error', message, data, error);
  }

  debug(message, data = {}) {
    if (process.env.LOG_LEVEL === 'debug') {
      this._log('debug', message, data);
    }
  }

  // Business metrics logging
  metric(name, value, unit = 'Count', dimensions = {}) {
    this._log('metric', `Custom metric: ${name}`, {
      metricName: name,
      metricValue: value,
      metricUnit: unit,
      metricDimensions: dimensions
    });
  }

  // Performance logging
  performance(operation, duration, metadata = {}) {
    this._log('performance', `Operation completed: ${operation}`, {
      operation,
      duration,
      durationUnit: 'ms',
      ...metadata
    });
  }

  // Security events
  security(event, details = {}) {
    this._log('security', `Security event: ${event}`, {
      securityEvent: event,
      ...details
    });
  }

  // Business events
  business(event, details = {}) {
    this._log('business', `Business event: ${event}`, {
      businessEvent: event,
      ...details
    });
  }
}

// Lambda wrapper with automatic logging
const withLogging = (handler, functionName) => {
  return async (event, context) => {
    const logger = new StructuredLogger({
      functionName,
      requestId: context.awsRequestId,
      functionVersion: context.functionVersion
    });

    // Set correlation ID from event or generate one
    const correlationId = event.headers?.['x-correlation-id'] || 
                         event.requestContext?.requestId || 
                         context.awsRequestId;
    logger.setCorrelationId(correlationId);

    const startTime = Date.now();

    try {
      logger.info('Function invocation started', {
        httpMethod: event.httpMethod,
        path: event.path,
        userAgent: event.headers?.['User-Agent']
      });

      // Add logger to event for use in handler
      event.logger = logger;

      const result = await handler(event, context);

      const duration = Date.now() - startTime;
      logger.performance('function_execution', duration, {
        statusCode: result.statusCode,
        success: true
      });

      logger.info('Function invocation completed successfully', {
        statusCode: result.statusCode,
        duration
      });

      return result;
    } catch (error) {
      const duration = Date.now() - startTime;
      
      logger.error('Function invocation failed', {
        duration,
        errorType: error.constructor.name
      }, error);

      // Return structured error response
      return {
        statusCode: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          success: false,
          error: {
            message: 'Internal server error',
            correlationId,
            timestamp: new Date().toISOString()
          }
        })
      };
    }
  };
};

module.exports = {
  StructuredLogger,
  withLogging
};