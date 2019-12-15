*** Settings ***

Documentation
...    A test suite for validating UE Area Subscribe (UEAREASUB) operations.

Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem 

Default Tags    TC_MEC_SRV_UEAREASUB



*** Test Cases ***

TC_MEC_SRV_UEAREASUB_001_OK
    [Documentation]
    ...    Check that the IUT acknowledges the UE area change subscription request when
    ...    commanded by a MEC Application and notifies it when the UE enters the specified circle
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.11
    ...    OpenAPI    # TODO check this

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Create new subscription    CircleNotificationSubscription
    Check HTTP Response Status Code Is    201
    Check HTTP Response Body Json Schema Is    CircleNotificationSubscription
    Should Be Equal As Strings    ${response['body']['circleNotificationSubscription']['callbackReference']}        ${APP_UEAREASUB_CALLBACK_URI}
    Should Be Equal As Strings    ${response['body']['circleNotificationSubscription']['address']}    ${IP_ADDRESS}
    


TC_MEC_SRV_UEAREASUB_001_BR
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request with incorrect parameters is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.11

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Create new subscription    CircleNotificationSubscriptionError
    Check HTTP Response Status Code Is    400


TC_MEC_SRV_UEAREASUB_002_OK
    [Documentation]
    ...    Check that the IUT acknowledges the cancellation of UE area change notifications
    ...    when commanded by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.6

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Remove subscription    ${SUBSCRIPTION_ID}
    Check HTTP Response Status Code Is    204


TC_MEC_SRV_UEAREASUB_002_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request sent by a MEC Application doesn't comply with a required condition
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.6

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Remove subscription    ${NON_EXISTENT_SUBSCRIPTION_ID}
    Check HTTP Response Status Code Is    404


*** Keywords ***
Create new subscription
    [Arguments]    ${content}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Content-Type":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    ${file}=    Catenate    SEPARATOR=    jsons/    ${content}    .json
    ${body}=    Get File    ${file}
    Post    ${apiRoot}/${apiName}/${apiVersion}/subscriptions/area/circle    ${body}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Remove subscription
    [Arguments]    ${subscriptionId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Delete    ${apiRoot}/${apiName}/${apiVersion}/subscriptions/area/circle/${subscriptionId}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}