const AWS = require("aws-sdk");

const dynamodb = new AWS.DynamoDB.DocumentClient({
  region: "eu-central-1"
});

const cloudwatch = new AWS.CloudWatch({
  region: "eu-central-1"
});

exports.handler = async (event) => {

  try {

    if (event.testError) {
      throw new Error("TEST ERROR");
    }

    const data = await dynamodb.scan({
      TableName: "users"
    }).promise();

    const users = data.Items.map(item => ({
      id: item.id,
      firstName: item.firstName,
      lastName: item.lastName
    }));

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
        "Access-Control-Allow-Headers": "*"
      },
      body: JSON.stringify(users)
    };

  } catch (err) {

    await cloudwatch.putMetricData({
      Namespace: "MyApp/Metrics",
      MetricData: [
        {
          MetricName: "AppErrors",
          Value: 1,
          Unit: "Count"
        }
      ]
    }).promise();

    throw err;
  }
};