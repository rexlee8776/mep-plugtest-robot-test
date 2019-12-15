*** Settings ***

Documentation
...    A test suite for validating UE Location Subscription (UELOCSUB) operations.


Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem 

Default Tags    TC_MEC_SRV_UELOCSUB


*** Variables ***
${response}

*** Test Cases ***

TC_MEC_SRV_UELOCSUB_001_OK
    [Documentation]
    ...    Check that the IUT acknowledges the UE location change subscription request
    ...    when commanded by a MEC Application and notifies it when the location changes
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.4
    ...    OpenAPI    https://forge.etsi.org/gitlab/mec/gs013-location-api/blob/master/LocationAPI.yaml#/definitions/UserTrackingSubscription

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Create new subscription    UserTrackingSubscription
    Check HTTP Response Status Code Is    201
    Check HTTP Response Body Json Schema Is    UserTrackingSubscription
    Check Result Contains    ${response['body']['userTrackingSubscription']}    clientCorrelator    ${USERTRACKSUB_CLIENT_ID}
    Check Result Contains    ${response['body']['userTrackingSubscription']}    callbackReference    ${USERTRACK_NOTIF_CALLBACK_URI}
    Check Result Contains    ${response['body']['userTrackingSubscription']}    address    ${USERTRACK_IP_ADDRESS}

    # TODO how to send this? The TP has the IUT doing this immediately. Do we want this or will it be discarded as part of the test?
    # // MEC 013, clause 7.3.4.3
    # the IUT entity sends a vPOST containing
    # Uri set to CALLBACK_URL 
    # body containing
    # zonalPresenceNotification containing
    # clientCorrelator set to CLIENT_ID, 
    # address set to IP_ADDRESS
    # ;
    # ;
    # ;
    # to the MEC_APP entity

TC_MEC_SRV_UELOCSUB_001_BR
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request with incorrect parameters is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.4

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Create new subscription    UserTrackingSubscriptionError
    Check HTTP Response Status Code Is    400


TC_MEC_SRV_UELOCSUB_002_OK
    [Documentation]
    ...    Check that the IUT acknowledges the cancellation of UE location change notifications
    ...    when commanded by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.6

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Remove subscription    ${SUBSCRIPTION_ID}
    Check HTTP Response Status Code Is    204


TC_MEC_SRV_UELOCSUB_002_NF
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
    Post    ${apiRoot}/${apiName}/${apiVersion}/subscriptions/userTracking    ${body}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    
Remove subscription  
    [Arguments]    ${subscriptionId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Delete    ${apiRoot}/${apiName}/${apiVersion}/subscriptions/userTracking/${subscriptionId}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}

