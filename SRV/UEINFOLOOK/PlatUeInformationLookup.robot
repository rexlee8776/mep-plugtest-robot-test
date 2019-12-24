*** Settings ***

Documentation
...    A test suite for validating UE Information Lookup (UEINFOLOOK) operations.

Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem 

Default Tags    TC_MEC_SRV_UEINFOLOOK


*** Test Cases ***

TC_MEC_SRV_UEINFOLOOK_001_OK
    [Documentation]
    ...    Check that the IUT responds with the information pertaining to one or more UEs in a particular location
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.3
    ...    OpenAPI    https://forge.etsi.org/gitlab/mec/gs013-location-api/blob/master/LocationAPI.yaml#/definitions/UserList

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES   INCLUDE_UNDEFINED_SCHEMAS
    Get list of users with filter    address    ${ACR_ADDRESS}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    UserList


TC_MEC_SRV_UEINFOLOOK_001_BR
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request with incorrect parameters is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.3

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get list of users with filter    addr    ${ACR_ADDRESS}
    Check HTTP Response Status Code Is    400


TC_MEC_SRV_UEINFOLOOK_001_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.3
    ...    OpenAPI    https://forge.etsi.org/gitlab/mec/gs013-location-api/blob/master/LocationAPI.yaml#/definitions/UserList

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get list of users with filter    address    ${ACR_UNKNOWN_IP}
    Check HTTP Response Status Code Is    404
    
*** Keywords ***
Get list of users with filter   
    [Arguments]     ${key}   ${value}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/users?${key}=${value}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
