export function request(ctx) {
    return {
        operation: 'PutItem',
        key: {
            formId: { S: "testFormId" }
        },
        attributeValues: {
            fieldName: { S: "testFieldValue" }
        }
    };
}
