*** Settings ***

Documentation
...    A test suite for validating Radio Node Location Lookup (RLOCLOOK) operations.

Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem 

Default Tags    TC_MEC_SRV_RLOCLOOK


*** Test Cases ***

TC_MEC_SRV_RLOCLOOK_001_OK
    [Documentation]
    ...    Check that the IUT responds with the list of radio nodes currently associated with the MEC host and the location of each radio node
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.7
    ...    OpenAPI    https://forge.etsi.org/gitlab/mec/gs013-location-api/blob/master/LocationAPI.yaml#/definitions/AccessPointList

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES    
    Get the access points list        ${ZONE_ID}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    AccessPointList
    Should Be Equal As Strings    ${response['body']['accessPointList']['zoneId']}	${ZONE_ID}


TC_MEC_SRV_RLOCLOOK_001_NF
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request for an unknown URI is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.7

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Get the access points list        ${NON_EXISTENT_ZONE_ID}
    Check HTTP Response Status Code Is    404
    

*** Keywords ***
Get the access points list 
    [Arguments]    ${zoneId}
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/zones/${zoneId}/accessPoints
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
