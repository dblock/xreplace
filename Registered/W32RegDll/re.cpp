#include <afx.h>
#include "regexp.h"
#include <iostream.h>
#include <fstream.h>

#define DllExport extern "C" __declspec( dllexport ) 

DllExport int Search(
    LPCSTR sSearchString, 
    LPCSTR sSearchExp, 
    LPCSTR sReplaceExp, 
    int& nPos, 
    int& offset, 
    int& pReplaceLen, 
    LPSTR& pReplaceStr, 
    LPCSTR& pError)
{
	CRegExp r;

    r.RegComp( sSearchExp );
	if ( (nPos = r.RegFind( sSearchString )) != -1){        
		pReplaceStr = r.GetReplaceString( sReplaceExp );
		pReplaceLen = r.GetFindLen();
        offset = nPos;
		pError = r.m_Error;
		return 1;
    } else {
		pError = r.m_Error;
		return 0;
	}

}

