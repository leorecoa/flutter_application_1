const AWS = require('aws-sdk');

class CostMonitor {
  constructor() {
    this.costExplorer = new AWS.CostExplorer({ region: 'us-east-1' });
    this.cloudWatch = new AWS.CloudWatch({ region: process.env.AWS_REGION || 'us-east-1' });
  }

  async getCurrentMonthCosts() {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0);

    const params = {
      TimePeriod: {
        Start: startOfMonth.toISOString().split('T')[0],
        End: endOfMonth.toISOString().split('T')[0]
      },
      Granularity: 'MONTHLY',
      Metrics: ['BlendedCost'],
      GroupBy: [
        {
          Type: 'DIMENSION',
          Key: 'SERVICE'
        }
      ],
      Filter: {
        Dimensions: {
          Key: 'SERVICE',
          Values: ['Amazon DynamoDB', 'AWS Lambda', 'Amazon API Gateway', 'Amazon Cognito']
        }
      }
    };

    try {
      const result = await this.costExplorer.getCostAndUsage(params).promise();
      return this.formatCostData(result);
    } catch (error) {
      console.error('Error fetching cost data:', error);
      throw error;
    }
  }

  formatCostData(data) {
    const costs = {};
    let totalCost = 0;

    data.ResultsByTime.forEach(timeResult => {
      timeResult.Groups.forEach(group => {
        const service = group.Keys[0];
        const cost = parseFloat(group.Metrics.BlendedCost.Amount);
        costs[service] = cost;
        totalCost += cost;
      });
    });

    return {
      totalCost: totalCost.toFixed(2),
      services: costs,
      currency: data.ResultsByTime[0]?.Groups[0]?.Metrics?.BlendedCost?.Unit || 'USD'
    };
  }

  async generateCostReport() {
    console.log('🔍 Generating cost report for AgendaFácil...\n');

    try {
      const costs = await this.getCurrentMonthCosts();

      console.log('💰 CURRENT MONTH COSTS:');
      console.log(`Total: $${costs.totalCost} ${costs.currency}`);
      console.log('\nBy Service:');
      Object.entries(costs.services).forEach(([service, cost]) => {
        console.log(`  ${service}: $${cost.toFixed(2)}`);
      });

      console.log('\n💡 OPTIMIZATION RECOMMENDATIONS:');
      
      if (costs.services['AWS Lambda'] > 10) {
        console.log('  - Consider optimizing Lambda function memory and timeout settings');
      }
      
      if (costs.totalCost > 50) {
        console.log('  - Review and optimize resource usage to reduce costs');
      }

      return costs;
    } catch (error) {
      console.error('Error generating cost report:', error);
      throw error;
    }
  }
}

if (require.main === module) {
  const monitor = new CostMonitor();
  monitor.generateCostReport()
    .then(() => console.log('\n✅ Cost report generated successfully'))
    .catch(error => {
      console.error('❌ Failed to generate cost report:', error);
      process.exit(1);
    });
}

module.exports = CostMonitor;