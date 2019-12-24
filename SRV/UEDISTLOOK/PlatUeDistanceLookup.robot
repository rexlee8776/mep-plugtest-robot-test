*** Settings ***

Documentation
...    A test suite for validating UE Distance Lookup (UEDISTLOOK) operations.

Resource    ../../GenericKeywords.robot
Resource    environment/variables.txt
Library     REST    ${SCHEMA}://${HOST}:${PORT}    ssl_verify=false
Library     OperatingSystem   

Default Tags    TC_MEC_SRV_UEDISTLOOK


*** Variables ***
${response}


*** Test Cases ***

TC_MEC_SRV_UEDISTLOOK_001_OK
    [Documentation]
    ...    Check that the IUT responds with the distance to a UE
    ...    when queried by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.9
    ...    OpenAPI    # TODO check this

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES   INCLUDE_UNDEFINED_SCHEMAS
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/queries/distance?address=${LOC_QRY_UE_ADDRESS}&latitude=${LOC_QRY_UE_LAT}&longitude=${LOC_QRY_UE_LONG}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    Check HTTP Response Status Code Is    200
    Check HTTP Response Body Json Schema Is    TerminalDistance


TC_MEC_SRV_UEDISTLOOK_001_BR
    [Documentation]
    ...    Check that the IUT responds with an error when
    ...    a request with incorrect parameters is sent by a MEC Application
    ...
    ...    Reference    ETSI GS MEC 013 V2.1.1, clause 7.3.9

    [Tags]    PIC_MEC_PLAT    PIC_SERVICES
    Set Headers    {"Accept":"application/json"}
    Set Headers    {"Authorization":"${TOKEN}"}
    Get    ${apiRoot}/${apiName}/${apiVersion}/queries/distance?address=${LOC_QRY_UE_ADDRESS}&lat=${LOC_QRY_UE_LAT}&longitude=${LOC_QRY_UE_LONG}
    ${output}=    Output    response
    Set Suite Variable    ${response}    ${output}
    Check HTTP Response Status Code Is    400
