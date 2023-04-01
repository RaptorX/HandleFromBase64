/** v0.1.0 | By RaptorX | [AHK Forum Post]()
 * Get a Handle for an icon or bitmap from a base64 string
 * ---
 *
 * ### Params:
 * - `Base64`            - Base64 encoded string
 * - `IsIcon` [Optional] - Determines wether to return an HICON OR HBITMAP
 *
 * ### Returns:
 * - returns
 * 	- `HICON`
 * 	- `HBITMAP`
 *
 * ### Examples:
 * Desc
 * ```
hIcon:=HandleFromBase64(b64ico)

main := Gui()
main.AddPicture('', 'HICON:' hIcon)
main.Show()
 * ```
 */
HandleFromBase64(Base64, IsIcon := true) {
	static CRYPT_STRING_BASE64 := 0x00000001

	GdiPlusStartupInput := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
	NumPut("uint", 1, GdiPlusStartupInput, 0) ; GdiPlusVersion


	; add parameter type checking
	if !DllCall("Crypt32\CryptStringToBinaryW",
	             "Str"  , Base64,
	             "UInt" , 0,
	             "UInt" , CRYPT_STRING_BASE64,
	             "Ptr"  , 0,
	             "Ptr*", &Size := 0,
	             "Ptr"  , 0,
	             "Ptr"  , 0)
		throw OSError()

	Decoded := Buffer(Size)
	if !DllCall("Crypt32\CryptStringToBinaryW",
	             "Str"  , Base64,
	             "UInt" , 0,
	             "UInt" , CRYPT_STRING_BASE64,
	             "Ptr"  , Decoded,
	             "Ptr*", &Size,
	             "Ptr"  , 0,
	             "Ptr"  , 0)
		throw OSError()

	if res := DllCall("GDIPlus\GdiplusStartup",
	                  "ptr*", &pToken := 0,
	                  "ptr", GdiPlusStartupInput,
	                  "ptr", 0)
		throw Error('Could not start the GDI library', A_ThisFunc, res)

	if !pStream := DllCall("shlwapi\SHCreateMemStream",
	                       "ptr", Decoded,
	                       "uint", Decoded.size, "ptr")
		throw Error('Could not create the memory stream', A_ThisFunc)

	DllCall "GDIPlus\GdipCreateBitmapFromStreamICM",
	        "ptr" , pStream,
	        "ptr*", &pBitmap := 0
	DllCall "GDIPlus\GdipCreateHICONFromBitmap",
	        "ptr" , pBitmap,
	        "ptr*", &hIcon := 0
	DllCall "GDIPlus\GdipCreateHBITMAPFromBitmap",
	        "ptr" , pBitmap,
	        "ptr*", &hBitmap := 0,
	        "int" , 0xffffffff

	ObjRelease(pStream)
	; DllCall "GDIPlus\GdiplusShutdown", "ptr", pToken
	return (IsIcon ? hIcon : hBitmap)
}