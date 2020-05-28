*** Settings ***

Documentation
...    A test suite for validating Application Subscriptions (APPSUB) operations.

Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem    

Default Tags    TC_MEC_SRV_APPSUB


*** Test Cases ***

TC_MEC_SRV_APPSUB_001_OK
    [Documentation]
    ...    Check that the IUT responds with a list of subscriptions for notifications
    ...    on services availability when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.3.3.1
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/MecAppSuptApiSubscriptionLinkList

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get Subscriptions list    ${APP_INSTANCE_ID}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    SubscriptionsLinkList


TC_MEC_SRV_APPSUB_001_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.3.3.1

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get Subscriptions list    ${NON_EXISTENT_APP_INSTANCE_ID}
    Check HTTP Response Status Code Is    404


TC_MEC_SRV_APPSUB_002_OK
    [Documentation]
    ...    Check that the IUT acknowledges the subscription by a MEC Application
    ...    to notifications on service availability events
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.3.3.4
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/AppTerminationNotificationSubscription

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Create new subscription    ${APP_INSTANCE_ID}    AppTerminationNotificationSubscription
    Check HTTP Response Status Code Is    201
    Check HTTP Response Body Json Schema Is    AppTerminationNotificationSubscription
    Check HTTP Response Header Contains    Location
    Check Result Contains    ${response['body']}    subscriptionType    "AppTerminationNotificationSubscription"
    Check Result Contains    ${response['body']}    callbackReference    ${APP_TERM_NOTIF_CALLBACK_URI}


TC_MEC_SRV_APPSUB_003_OK
    [Documentation]
    ...    Check that the IUT responds with the information on a specific subscription
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.4.3.1
    ...    OpenAPI    https://forge.etsi.org/rep/mec/gs011-app-enablement-api/blob/master/MecAppSupportApi.yaml#/definitions/AppTerminationNotificationSubscription

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get individual subscription    ${APP_INSTANCE_ID}    ${SUBSCRIPTION_ID}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    AppTerminationNotificationSubscription
    Check Result Contains    ${response['body']}    subscriptionType    "AppTerminationNotificationSubscription"


TC_MEC_SRV_APPSUB_003_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.4.3.1

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get individual subscription    ${APP_INSTANCE_ID}    ${NON_EXISTENT_SUBSCRIPTION_ID}
    Check HTTP Response Status Code Is    404


TC_MEC_SRV_APPSUB_004_OK
    [Documentation]
    ...    Check that the IUT acknowledges the unsubscribe from service availability event notifications
    ...    when commanded by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.1.1, clause 7.2.4.3.5

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Remove subscription    ${APP_INSTANCE_ID}    ${SUBSCRIPTION_ID}
    Check HTTP Response Status Code Is    204


TC_MEC_SRV_APPSUB_004_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 011 V2.0.9, clause 7.2.4.3.5

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Remove subscription    ${NON_EXISTENT_APP_INSTANCE_ID}    ${SUBSCRIPTION_ID}
    Check HTTP Response Status Code Is    404


*** Keywords ***
Get Subscriptions List
    [Arguments]    ${appInstanceId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/applications/${appInstanceId}/subscriptions
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Create new subscription    
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