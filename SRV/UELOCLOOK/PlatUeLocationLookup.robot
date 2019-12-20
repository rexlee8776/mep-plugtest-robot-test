*** Settings ***

Documentation
...    A test suite for validating UE Location Lookup (UELOCLOOK) operations.


Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem 

Default Tags    TC_MEC_SRV_UELOCLOOK

*** Variables ***
${response}

*** Test Cases ***

TC_MEC_SRV_UELOCLOOK_001_OK
    [Documentation]
    ...    Check that the IUT responds with a list for the location of User Equipments
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.3
    ...    OpenAPI    https://forge.etsi.org/gitlab/mec/gs013-location-api/blob/master/LocationAPI.yaml#/definitions/UserInfo

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get list of user equipments    zoneId    ${ZONE_ID}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    UserList
    Check Result Contains    ${response['body']['userList']['user']}    zoneId    ${ZONE_ID}


TC_MEC_SRV_UELOCLOOK_001_BR
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request with incorrect parameters is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.3

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get list of user equipments    zone    ${ZONE_ID}
    Check HTTP Response Status Code Is    400


TC_MEC_SRV_UELOCLOOK_001_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.2

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get list of user equipments    zoneId    ${NON_EXISTENT_ZONE_ID}
    Check HTTP Response Status Code Is    404




TC_MEC_SRV_UELOCLOOK_002_OK
    [Documentation]
    ...    Check that the IUT responds with a User Equipment information 
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.2
    ...    OpenAPI    https://forge.etsi.org/gitlab/mec/gs013-location-api/blob/master/LocationAPI.yaml#/definitions/UserInfo

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get specific user equipments    ${USER_ID}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    UserInfo
    

TC_MEC_SRV_UELOCLOOK_002_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.2

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get specific user equipments    ${NON_EXISTENT_USER_ID}
    Check HTTP Response Status Code Is    404

*** Keywords ***
Get list of user equipments
    [Arguments]    ${key}   ${value}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/users?${key}=${value}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}


Get specific user equipments
    [Arguments]    ${userId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/users/${userId}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
