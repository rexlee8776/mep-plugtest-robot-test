*** Settings ***

Documentation
...    A test suite for validating UE Information Subscription (UEINFOSUB) operations.

Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem  

Default Tags    TC_MEC_SRV_UEINFOSUB


*** Test Cases ***

TC_MEC_SRV_UEINFOSUB_001_OK
    [Documentation]
    ...    Check that the IUT acknowledges the UE information change subscription request
    ...    when commanded by a MEC Application and notifies it when the location changes
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.5
    ...    OpenAPI    https://forge.etsi.org/gitlab/mec/gs013-location-api/blob/master/LocationAPI.yaml#/definitions/zonalTrafficSubscription

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Create new subscription    ZonalTrafficSubscription
    Check HTTP Response Status Code Is    201
    Check HTTP Response Body Json Schema Is    ZonalTrafficSubscription
    Should Be Equal As Strings    ${response['body']['zonalTrafficSubscription']['zoneId']}        ${ZONAL_TRAF_ZONE_ID}
    Should Be Equal As Strings    ${response['body']['zonalTrafficSubscription']['clientCorrelator']}    ${ZONAL_TRAF_SUB_CLIENT_ID}
    Should Be Equal As Strings    ${response['body']['zonalTrafficSubscription']['callbackReference']}        ${ZONAL_TRAF_NOTIF_CALLBACK_URI}


TC_MEC_SRV_UEINFOSUB_001_BR
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request with incorrect parameters is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.5
    ...    OpenAPI    https://forge.etsi.org/gitlab/mec/gs013-location-api/blob/master/LocationAPI.yaml#/definitions/zonalTrafficSubscription

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Create new subscription    ZonalTrafficSubscriptionError
    Check HTTP Response Status Code Is    400


TC_MEC_SRV_UEINFOSUB_002_OK
    [Documentation]
    ...    Check that the IUT acknowledges the cancellation of UE information change notifications
    ...    when commanded by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.6

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Remove subscription    ${SUBSCRIPTION_ID}
    Check HTTP Response Status Code Is    204


TC_MEC_SRV_UEINFOSUB_002_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
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
    Post    ${apiRoot}/${apiName}/${apiVersion}/subscriptions/zonalTraffic    ${body}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Remove subscription  
    [Arguments]    ${subscriptionId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Delete    ${apiRoot}/${apiName}/${apiVersion}/subscriptions/zonalTraffic/${subscriptionId}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}


