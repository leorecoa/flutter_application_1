const AWS = require('aws-sdk');
const cloudwatch = new AWS.CloudWatch();
const dynamodb = new AWS.DynamoDB();
const lambda = new AWS.Lambda();
const applicationAutoscaling = new AWS.ApplicationAutoScaling();

/**
 * Analisa padrões de uso e ajusta configurações de auto-scaling
 */
class UsageAnalyzer {
  constructor(config) {
    this.config = {
      environment: process.env.ENVIRONMENT || 'dev',
      dynamodbTable: process.env.DYNAMODB_TABLE || 'AgendaFacilTable',
      lambdaFunctionPrefix: process.env.LAMBDA_FUNCTION_PREFIX || 'agenda-facil',
      ...config
    };
  }
  
  /**
   * Analisa métricas de uso e ajusta configurações de auto-scaling
   */
  async analyzeAndAdjust() {
    console.log('Starting usage analysis...');
    
    try {
      // Analisa padrões de uso do DynamoDB
      const dynamoDbPatterns = await this.analyzeDynamoDbUsage();
      
      // Analisa padrões de uso do Lambda
      const lambdaPatterns = await this.analyzeLambdaUsage();
      
      // Ajusta configurações de auto-scaling com base nos padrões
      await this.adjustDynamoDbScaling(dynamoDbPatterns);
      await this.adjustLambdaScaling(lambdaPatterns);
      
      console.log('Usage analysis and adjustments completed successfully');
      return {
        dynamoDbPatterns,
        lambdaPatterns,
        success: true
      };
    } catch (error) {
      console.error('Error in usage analysis:', error);
      return {
        error: error.message,
        success: false
      };
    }
  }
  
  /**
   * Analisa padrões de uso do DynamoDB
   */
  async analyzeDynamoDbUsage() {
    console.log('Analyzing DynamoDB usage patterns...');
    
    // Obtém métricas de uso do DynamoDB nas últimas 2 semanas
    const endTime = new Date();
    const startTime = new Date(endTime);
    startTime.setDate(startTime.getDate() - 14);
    
    const readMetrics = await this.getCloudWatchMetrics({
      MetricName: 'ConsumedReadCapacityUnits',
      Namespace: 'AWS/DynamoDB',
      Dimensions: [
        {
          Name: 'TableName',
          Value: this.config.dynamodbTable
        }
      ],
      StartTime: startTime,
      EndTime: endTime,
      Period: 3600, // 1 hora
      Statistics: ['Sum', 'Maximum', 'Average']
    });
    
    const writeMetrics = await this.getCloudWatchMetrics({
      MetricName: 'ConsumedWriteCapacityUnits',
      Namespace: 'AWS/DynamoDB',
      Dimensions: [
        {
          Name: 'TableName',
          Value: this.config.dynamodbTable
        }
      ],
      StartTime: startTime,
      EndTime: endTime,
      Period: 3600, // 1 hora
      Statistics: ['Sum', 'Maximum', 'Average']
    });
    
    // Analisa padrões por hora do dia e dia da semana
    const hourlyPatterns = this.analyzeHourlyPatterns(readMetrics.Datapoints, writeMetrics.Datapoints);
    const dailyPatterns = this.analyzeDailyPatterns(readMetrics.Datapoints, writeMetrics.Datapoints);
    
    // Identifica picos e vales
    const readPeaks = this.identifyPeaks(readMetrics.Datapoints, 'Sum');
    const writePeaks = this.identifyPeaks(writeMetrics.Datapoints, 'Sum');
    
    return {
      hourlyPatterns,
      dailyPatterns,
      readPeaks,
      writePeaks,
      readMetrics: readMetrics.Datapoints,
      writeMetrics: writeMetrics.Datapoints
    };
  }
  
  /**
   * Analisa padrões de uso do Lambda
   */
  async analyzeLambdaUsage() {
    console.log('Analyzing Lambda usage patterns...');
    
    // Obtém métricas de uso do Lambda nas últimas 2 semanas
    const endTime = new Date();
    const startTime = new Date(endTime);
    startTime.setDate(startTime.getDate() - 14);
    
    const functions = [
      `${this.config.lambdaFunctionPrefix}-${this.config.environment}-AuthFunction`,
      `${this.config.lambdaFunctionPrefix}-${this.config.environment}-AppointmentsFunction`,
      `${this.config.lambdaFunctionPrefix}-${this.config.environment}-ServicesFunction`,
      `${this.config.lambdaFunctionPrefix}-${this.config.environment}-TenantFunction`
    ];
    
    const metricsPromises = functions.map(async (functionName) => {
      const invocations = await this.getCloudWatchMetrics({
        MetricName: 'Invocations',
        Namespace: 'AWS/Lambda',
        Dimensions: [
          {
            Name: 'FunctionName',
            Value: functionName
          }
        ],
        StartTime: startTime,
        EndTime: endTime,
        Period: 3600, // 1 hora
        Statistics: ['Sum']
      });
      
      const duration = await this.getCloudWatchMetrics({
        MetricName: 'Duration',
        Namespace: 'AWS/Lambda',
        Dimensions: [
          {
            Name: 'FunctionName',
            Value: functionName
          }
        ],
        StartTime: startTime,
        EndTime: endTime,
        Period: 3600, // 1 hora
        Statistics: ['Average', 'Maximum']
      });
      
      return {
        functionName,
        invocations: invocations.Datapoints,
        duration: duration.Datapoints
      };
    });
    
    const metricsResults = await Promise.all(metricsPromises);
    
    // Analisa padrões por hora do dia e dia da semana
    const hourlyPatterns = {};
    const dailyPatterns = {};
    const peaks = {};
    
    metricsResults.forEach(result => {
      const { functionName, invocations } = result;
      hourlyPatterns[functionName] = this.analyzeHourlyPatterns(invocations);
      dailyPatterns[functionName] = this.analyzeDailyPatterns(invocations);
      peaks[functionName] = this.identifyPeaks(invocations, 'Sum');
    });
    
    return {
      functionMetrics: metricsResults,
      hourlyPatterns,
      dailyPatterns,
      peaks
    };
  }
  
  /**
   * Ajusta configurações de auto-scaling do DynamoDB com base nos padrões
   */
  async adjustDynamoDbScaling(patterns) {
    console.log('Adjusting DynamoDB auto-scaling settings...');
    
    // Calcula capacidade mínima e máxima com base nos padrões
    const readStats = this.calculateCapacityStats(patterns.readMetrics, 'Sum');
    const writeStats = this.calculateCapacityStats(patterns.writeMetrics, 'Sum');
    
    // Adiciona margem de segurança
    const minReadCapacity = Math.max(5, Math.ceil(readStats.avg * 0.5));
    const maxReadCapacity = Math.max(100, Math.ceil(readStats.max * 1.5));
    const minWriteCapacity = Math.max(5, Math.ceil(writeStats.avg * 0.5));
    const maxWriteCapacity = Math.max(100, Math.ceil(writeStats.max * 1.5));
    
    // Ajusta configurações de auto-scaling
    await this.updateScalableTarget({
      ServiceNamespace: 'dynamodb',
      ResourceId: `table/${this.config.dynamodbTable}`,
      ScalableDimension: 'dynamodb:table:ReadCapacityUnits',
      MinCapacity: minReadCapacity,
      MaxCapacity: maxReadCapacity
    });
    
    await this.updateScalableTarget({
      ServiceNamespace: 'dynamodb',
      ResourceId: `table/${this.config.dynamodbTable}`,
      ScalableDimension: 'dynamodb:table:WriteCapacityUnits',
      MinCapacity: minWriteCapacity,
      MaxCapacity: maxWriteCapacity
    });
    
    // Ajusta configurações de auto-scaling para GSI
    try {
      await this.updateScalableTarget({
        ServiceNamespace: 'dynamodb',
        ResourceId: `table/${this.config.dynamodbTable}/index/GSI1`,
        ScalableDimension: 'dynamodb:index:ReadCapacityUnits',
        MinCapacity: minReadCapacity,
        MaxCapacity: maxReadCapacity
      });
      
      await this.updateScalableTarget({
        ServiceNamespace: 'dynamodb',
        ResourceId: `table/${this.config.dynamodbTable}/index/GSI1`,
        ScalableDimension: 'dynamodb:index:WriteCapacityUnits',
        MinCapacity: minWriteCapacity,
        MaxCapacity: maxWriteCapacity
      });
    } catch (error) {
      console.warn('GSI scaling adjustment failed, might not exist:', error.message);
    }
    
    return {
      readCapacity: { min: minReadCapacity, max: maxReadCapacity },
      writeCapacity: { min: minWriteCapacity, max: maxWriteCapacity }
    };
  }
  
  /**
   * Ajusta configurações de auto-scaling do Lambda com base nos padrões
   */
  async adjustLambdaScaling(patterns) {
    console.log('Adjusting Lambda auto-scaling settings...');
    
    // Identifica a função com maior uso
    const functionMetrics = patterns.functionMetrics;
    let highestUsageFunction = null;
    let maxInvocations = 0;
    
    functionMetrics.forEach(metric => {
      const totalInvocations = metric.invocations.reduce((sum, dp) => sum + dp.Sum, 0);
      if (totalInvocations > maxInvocations) {
        maxInvocations = totalInvocations;
        highestUsageFunction = metric.functionName;
      }
    });
    
    if (!highestUsageFunction) {
      console.log('No function usage data available');
      return null;
    }
    
    // Obtém padrões da função com maior uso
    const functionPatterns = patterns.hourlyPatterns[highestUsageFunction];
    
    // Calcula concorrência provisionada com base nos padrões
    const peakHours = Object.entries(functionPatterns)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([hour]) => parseInt(hour));
    
    // Configura ações programadas para os horários de pico
    for (const hour of peakHours) {
      const scheduleName = `${this.config.environment}-ScaleUp-Hour-${hour}`;
      const scheduleExpression = `cron(0 ${hour} * * ? *)`;
      
      try {
        await this.putScheduledAction({
          ServiceNamespace: 'lambda',
          ResourceId: `function:${highestUsageFunction}:prod`,
          ScalableDimension: 'lambda:function:ProvisionedConcurrency',
          ScheduledActionName: scheduleName,
          Schedule: scheduleExpression,
          ScalableTargetAction: {
            MinCapacity: 20
          }
        });
        
        // Configura redução após o horário de pico
        const scaleDownHour = (hour + 3) % 24;
        const scaleDownName = `${this.config.environment}-ScaleDown-Hour-${scaleDownHour}`;
        const scaleDownExpression = `cron(0 ${scaleDownHour} * * ? *)`;
        
        await this.putScheduledAction({
          ServiceNamespace: 'lambda',
          ResourceId: `function:${highestUsageFunction}:prod`,
          ScalableDimension: 'lambda:function:ProvisionedConcurrency',
          ScheduledActionName: scaleDownName,
          Schedule: scaleDownExpression,
          ScalableTargetAction: {
            MinCapacity: 5
          }
        });
      } catch (error) {
        console.warn(`Failed to set scheduled action for hour ${hour}:`, error.message);
      }
    }
    
    return {
      highestUsageFunction,
      peakHours
    };
  }
  
  /**
   * Obtém métricas do CloudWatch
   */
  async getCloudWatchMetrics(params) {
    return cloudwatch.getMetricStatistics(params).promise();
  }
  
  /**
   * Atualiza configurações de auto-scaling
   */
  async updateScalableTarget(params) {
    try {
      await applicationAutoscaling.registerScalableTarget(params).promise();
      console.log(`Updated scalable target: ${params.ResourceId} - ${params.ScalableDimension}`);
      return true;
    } catch (error) {
      console.error(`Failed to update scalable target: ${params.ResourceId}`, error);
      throw error;
    }
  }
  
  /**
   * Configura ação programada de auto-scaling
   */
  async putScheduledAction(params) {
    try {
      await applicationAutoscaling.putScheduledAction(params).promise();
      console.log(`Put scheduled action: ${params.ScheduledActionName} - ${params.Schedule}`);
      return true;
    } catch (error) {
      console.error(`Failed to put scheduled action: ${params.ScheduledActionName}`, error);
      throw error;
    }
  }
  
  /**
   * Analisa padrões por hora do dia
   */
  analyzeHourlyPatterns(datapoints, additionalDatapoints = []) {
    const hourlyUsage = {};
    
    // Inicializa contadores para cada hora
    for (let i = 0; i < 24; i++) {
      hourlyUsage[i] = 0;
    }
    
    // Processa datapoints primários
    datapoints.forEach(dp => {
      const hour = new Date(dp.Timestamp).getUTCHours();
      hourlyUsage[hour] += dp.Sum || 0;
    });
    
    // Processa datapoints adicionais, se fornecidos
    additionalDatapoints.forEach(dp => {
      const hour = new Date(dp.Timestamp).getUTCHours();
      hourlyUsage[hour] += dp.Sum || 0;
    });
    
    return hourlyUsage;
  }
  
  /**
   * Analisa padrões por dia da semana
   */
  analyzeDailyPatterns(datapoints, additionalDatapoints = []) {
    const dailyUsage = {
      0: 0, // Domingo
      1: 0, // Segunda
      2: 0, // Terça
      3: 0, // Quarta
      4: 0, // Quinta
      5: 0, // Sexta
      6: 0  // Sábado
    };
    
    // Processa datapoints primários
    datapoints.forEach(dp => {
      const day = new Date(dp.Timestamp).getUTCDay();
      dailyUsage[day] += dp.Sum || 0;
    });
    
    // Processa datapoints adicionais, se fornecidos
    additionalDatapoints.forEach(dp => {
      const day = new Date(dp.Timestamp).getUTCDay();
      dailyUsage[day] += dp.Sum || 0;
    });
    
    return dailyUsage;
  }
  
  /**
   * Identifica picos de uso
   */
  identifyPeaks(datapoints, statistic) {
    if (!datapoints || datapoints.length === 0) {
      return { peaks: [], valleys: [] };
    }
    
    // Ordena datapoints por timestamp
    const sortedDatapoints = [...datapoints].sort((a, b) => 
      new Date(a.Timestamp) - new Date(b.Timestamp)
    );
    
    // Extrai valores
    const values = sortedDatapoints.map(dp => dp[statistic] || 0);
    
    // Calcula média e desvio padrão
    const avg = values.reduce((sum, val) => sum + val, 0) / values.length;
    const stdDev = Math.sqrt(
      values.reduce((sum, val) => sum + Math.pow(val - avg, 2), 0) / values.length
    );
    
    // Define limites para picos e vales
    const peakThreshold = avg + 1.5 * stdDev;
    const valleyThreshold = avg - 1.5 * stdDev;
    
    // Identifica picos e vales
    const peaks = sortedDatapoints.filter(dp => (dp[statistic] || 0) > peakThreshold);
    const valleys = sortedDatapoints.filter(dp => (dp[statistic] || 0) < valleyThreshold);
    
    return {
      peaks: peaks.map(dp => ({
        timestamp: dp.Timestamp,
        value: dp[statistic],
        hour: new Date(dp.Timestamp).getUTCHours(),
        day: new Date(dp.Timestamp).getUTCDay()
      })),
      valleys: valleys.map(dp => ({
        timestamp: dp.Timestamp,
        value: dp[statistic],
        hour: new Date(dp.Timestamp).getUTCHours(),
        day: new Date(dp.Timestamp).getUTCDay()
      })),
      avg,
      stdDev,
      peakThreshold,
      valleyThreshold
    };
  }
  
  /**
   * Calcula estatísticas de capacidade
   */
  calculateCapacityStats(datapoints, statistic) {
    if (!datapoints || datapoints.length === 0) {
      return { min: 5, max: 100, avg: 20 };
    }
    
    const values = datapoints.map(dp => dp[statistic] || 0);
    const max = Math.max(...values);
    const min = Math.min(...values);
    const avg = values.reduce((sum, val) => sum + val, 0) / values.length;
    
    return { min, max, avg };
  }
}

// Exporta a classe
module.exports = UsageAnalyzer;

// Se executado diretamente
if (require.main === module) {
  const analyzer = new UsageAnalyzer();
  analyzer.analyzeAndAdjust()
    .then(result => console.log('Analysis result:', JSON.stringify(result, null, 2)))
    .catch(error => console.error('Analysis failed:', error));
}