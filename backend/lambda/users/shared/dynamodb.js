const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

const TABLE_NAME = process.env.DYNAMODB_TABLE;

class DynamoDBService {
  static async getItem(pk, sk) {
    try {
      const params = {
        TableName: TABLE_NAME,
        Key: { PK: pk, SK: sk }
      };
      
      const result = await dynamodb.get(params).promise();
      return result.Item;
    } catch (error) {
      console.error('DynamoDB GetItem Error:', error);
      throw error;
    }
  }

  static async putItem(item) {
    try {
      const params = {
        TableName: TABLE_NAME,
        Item: {
          ...item,
          createdAt: item.createdAt || new Date().toISOString(),
          updatedAt: new Date().toISOString()
        }
      };
      
      await dynamodb.put(params).promise();
      return params.Item;
    } catch (error) {
      console.error('DynamoDB PutItem Error:', error);
      throw error;
    }
  }

  static async updateItem(pk, sk, updateExpression, expressionAttributeValues, expressionAttributeNames = {}) {
    try {
      const params = {
        TableName: TABLE_NAME,
        Key: { PK: pk, SK: sk },
        UpdateExpression: updateExpression,
        ExpressionAttributeValues: {
          ...expressionAttributeValues,
          ':updatedAt': new Date().toISOString()
        },
        ExpressionAttributeNames: expressionAttributeNames,
        ReturnValues: 'ALL_NEW'
      };

      const result = await dynamodb.update(params).promise();
      return result.Attributes;
    } catch (error) {
      console.error('DynamoDB UpdateItem Error:', error);
      throw error;
    }
  }

  static async deleteItem(pk, sk) {
    try {
      const params = {
        TableName: TABLE_NAME,
        Key: { PK: pk, SK: sk }
      };
      
      await dynamodb.delete(params).promise();
      return true;
    } catch (error) {
      console.error('DynamoDB DeleteItem Error:', error);
      throw error;
    }
  }

  static async query(pk, skBeginsWith = null, indexName = null) {
    try {
      const params = {
        TableName: TABLE_NAME,
        KeyConditionExpression: indexName ? 'GSI1PK = :pk' : 'PK = :pk',
        ExpressionAttributeValues: { ':pk': pk }
      };

      if (indexName) {
        params.IndexName = indexName;
      }

      if (skBeginsWith) {
        params.KeyConditionExpression += indexName ? ' AND begins_with(GSI1SK, :sk)' : ' AND begins_with(SK, :sk)';
        params.ExpressionAttributeValues[':sk'] = skBeginsWith;
      }

      const result = await dynamodb.query(params).promise();
      return result.Items;
    } catch (error) {
      console.error('DynamoDB Query Error:', error);
      throw error;
    }
  }

  static async scan(filterExpression = null, expressionAttributeValues = {}) {
    try {
      const params = { TableName: TABLE_NAME };
      
      if (filterExpression) {
        params.FilterExpression = filterExpression;
        params.ExpressionAttributeValues = expressionAttributeValues;
      }

      const result = await dynamodb.scan(params).promise();
      return result.Items;
    } catch (error) {
      console.error('DynamoDB Scan Error:', error);
      throw error;
    }
  }
}

module.exports = DynamoDBService;