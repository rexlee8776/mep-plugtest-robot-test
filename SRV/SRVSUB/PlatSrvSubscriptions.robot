*** Settings ***

Documentation
...    A test suite for validating Service Subscriptions (SRVSUB) operations.

Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem 

Default Tags    TC_MEC_SRV_SRVSUB


*** Test Cases ***

TC_MEC_SRV_SRVSUB_001_OK
    [Documentation]
    ...    Check that the IUT responds with a list of subscriptions for notifications
    ...    on services availability when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 8.2.8.3.1
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecServiceMgmtApi.yaml#/definitions/MecServiceMgmtApiSubscriptionLinkList

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get list of subscriptions    ${APP_INSTANCE_ID}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    SubscriptionLinkList


TC_MEC_SRV_SRVSUB_001_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 8.2.8.3.1

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get list of subscriptions    ${NON_EXISTENT_INSTANCE_ID}
    Check HTTP Response Status Code Is    404


TC_MEC_SRV_SRVSUB_002_OK
    [Documentation]
    ...    Check that the IUT acknowledges the subscription by a MEC Application
    ...    to notifications on service availability events
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 8.2.8.3.4
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecServiceMgmtApi.yaml#/definitions/SerAvailabilityNotificationSubscription

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Create a new subscription    ${APP_INSTANCE_ID}    SerAvailabilityNotificationSubscription
    Check HTTP Response Status Code Is    201
    Check HTTP Response Body Json Schema Is    SerAvailabilityNotificationSubscription
    Check HTTP Response Header Contains    Location
    Check Result Contains    ${response['body']}    subscriptionType    "SerAvailabilityNotificationSubscription"
    Check Result Contains    ${response['body']}    callbackReference    ${APP_SRVSUB_NOTIF_CALLBACK_URI}


TC_MEC_SRV_SRVSUB_002_BR
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request with incorrect parameters is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 8.2.8.3.4
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecServiceMgmtApi.yaml#/definitions/SerAvailabilityNotificationSubscription

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Create a new subscription    ${APP_INSTANCE_ID}    SerAvailabilityNotificationSubscriptionError
    Check HTTP Response Status Code Is    400


TC_MEC_SRV_SRVSUB_003_OK
    [Documentation]
    ...    Check that the IUT responds with the information on a specific subscription
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 8.2.9.3.1
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecServiceMgmtApi.yaml#/definitions/SerAvailabilityNotificationSubscription

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get individual subscription    ${APP_INSTANCE_ID}    ${SUBSCRIPTION_ID}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    SerAvailabilityNotificationSubscription
    Check Result Contains    ${response['body']}    subscriptionType    "SerAvailabilityNotificationSubscription"


TC_MEC_SRV_SRVSUB_003_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 8.2.9.3.1

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get individual subscription    ${APP_INSTANCE_ID}    ${NON_EXISTENT_SUBSCRIPTION_ID}
    Check HTTP Response Status Code Is    404


TC_MEC_SRV_SRVSUB_004_OK
    [Documentation]
    ...    Check that the IUT acknowledges the unsubscribe from service availability event notifications
    ...    when commanded by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 8.2.9.3.5

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Remove subscription    ${APP_INSTANCE_ID}    ${SUBSCRIPTION_ID}
    Check HTTP Response Status Code Is    204


TC_MEC_SRV_SRVSUB_004_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 8.2.9.3.5

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Remove subscription    ${NON_EXISTENT_INSTANCE_ID}    ${SUBSCRIPTION_ID}
    Check HTTP Response Status Code Is    404


*** Keywords ***
Get list of subscriptions    
    [Arguments]    ${appInstanceId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/applications/${appInstanceId}/subscriptions
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Create a new subscription   
    [Arguments]    ${appInstanceId}    ${content}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Content-Type":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    ${file}=    Catenate    SEPARATOR=    jsons/    ${content}    .json
    ${body}=    Get File    ${file}
    Post    ${apiRoot}/${apiName}/${apiVersion}/applications/${appInstanceId}/subscriptions    ${body}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Get individual subscription 
    [Arguments]    ${appInstanceId}    ${subscriptionId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/applications/${appInstanceId}/subscriptions/${subscriptionId}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Remove subscription    
    [Arguments]    ${appInstanceId}    ${subscriptionId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Delete    ${apiRoot}/${apiName}/${apiVersion}/applications/${appInstanceId}/subscriptions/${subscriptionId}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}