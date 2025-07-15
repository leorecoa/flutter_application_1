import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand, UpdateCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);
const TABLE_NAME = process.env.MAIN_TABLE;

export const handler = async (event) => {
    console.log('Auto-complete appointments started');
    
    try {
        const now = new Date().toISOString();
        
        const params = {
            TableName: TABLE_NAME,
            IndexName: 'AppointmentsByStatusIndex',
            KeyConditionExpression: 'GSI2PK = :status AND GSI2SK < :now',
            ExpressionAttributeValues: {
                ':status': 'confirmado',
                ':now': now
            }
        };

        const { Items } = await docClient.send(new QueryCommand(params));
        
        if (!Items || Items.length === 0) {
            return { statusCode: 200, body: 'No appointments to process' };
        }
        
        const updatePromises = Items.map(async (item) => {
            const updateParams = {
                TableName: TABLE_NAME,
                Key: { PK: item.PK, SK: item.SK },
                UpdateExpression: 'set #status = :newStatus, GSI2PK = :newStatus, updatedAt = :updatedAt',
                ExpressionAttributeNames: { '#status': 'status' },
                ExpressionAttributeValues: {
                    ':newStatus': 'concluido',
                    ':updatedAt': now
                }
            };
            
            return docClient.send(new UpdateCommand(updateParams));
        });

        await Promise.all(updatePromises);
        
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: `Auto-completed ${Items.length} appointments`,
                processedCount: Items.length
            })
        };
        
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Failed to auto-complete appointments' })
        };
    }
};