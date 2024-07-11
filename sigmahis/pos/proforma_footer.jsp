<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.StringTokenizer"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
		SQLMgr.setConnection(ConMgr);

		String mode=request.getParameter("mode");
		String change=request.getParameter("change");
		String id = request.getParameter("id");
		String fp = request.getParameter("fp");
		String fg = request.getParameter("fg");
		String cds = request.getParameter("cds");
		String almacen = request.getParameter("almacen");
		String familia = request.getParameter("familia");
		String tipo_pos = request.getParameter("tipo_pos");
		String artType = request.getParameter("artType");
		String cajero = request.getParameter("cajero");
		String caja = request.getParameter("caja");
		System.out.println("caja................="+caja);

		if(mode==null) mode="add";
		if(fp==null) fp="";
		if(fg==null) fg="";
%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<tr>
				<td colspan="2" width="87%">
					<table align="center" width="100%" cellpadding="1" cellspacing="1" class="TableLeftBorder TableTopBorder TableRightBorder TableBottomBorder">
					<tr class="TextHeader02">
						<td align="right" class="text14">Subtotal (E.)<input type="text" name="subtotal_exe" id="subtotal_exe" value="0.00" class="text14 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0"></td>
						<td align="right" class="text14">Desc. (E.)<input type="text" name="descuento_exe" id="descuento_exe" value="0.00" class="text14 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0"></td>
						<td align="right" class="text14">Subtotal <input type="text" name="subtotal_neto" id="subtotal_neto" value="0.00" class="text14 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0"></td>
							<input type="hidden" id="aplicadoDisplay" name="aplicadoDisplay" value="0">
						<td align="right" class="TextHeader text14">Pago<input type="text" name="pagoTotal" id="pagoTotal" value="0.00" class="text14 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0" readOnly></td>
						<td align="right" class="TextHeader text14">Articulos <input type="text" name="total_articulos" id="total_articulos" value="0" class="text14 FormDataObjectEnabled" style="text-align:right;" size="3" maxLength="3.0" readonly></td>
					</tr>
					<tr class="TextHeader02">
						<td align="right" class="text14">Subtotal (No E.)<input type="text" name="subtotal_no_exe" id="subtotal_no_exe" value="0.00" class="text14 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0"></td>
						<td align="right" class="text14">Desc. (No E.)<input type="text" name="descuento_no_exe" id="descuento_no_exe" value="0.00" class="text14 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0"></td>
						<td align="right" class="text14">ITBM<input type="text" name="itbm" id="itbm" value="0.00" class="text14 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0"></td>
						<td align="right" class="TextHeader text14">Total<input type="text" name="total" id="total" value="0.00" onChange="javascript:checkCredit();" class="text14 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0" readOnly></td>
						<td align="right" class="TextHeader">Cambio<input type="text" name="porAplicar" id="porAplicar" value="0.00" class="text14 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0" readOnly></td>
					</tr>
					</table>
				</td>
				<td colspan="2" width="13%" valign="top">
					<table align="center" width="100%" cellpadding="1" cellspacing="1" class="TableLeftBorder TableTopBorder TableRightBorder TableBottomBorder">
					<tr class="TextRow02">
						<td class="TextLabel" align="right">
						<input type="hidden" name="dgi" id="dgi" value="Y">
						   <input type="button" name="save" id="save" value="Guardar" onClick="javascript:doSubmit(this.value)">
						</td>
					</tr>
					<tr class="TextRow02">
						<td class="TextLabel" align="right">

						<input type="button" name="cancel" id="cancel" value="Cancelar" onClick="window.location.reload(true);">
						</td>
					</tr>
					</table>
				</td>
			</tr>
		</table>
	</td>
</tr>
</table>
