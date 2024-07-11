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
		String tipo = request.getParameter("tipo");
		String artType = request.getParameter("artType");
		String cajero = request.getParameter("cajero");
		String caja = request.getParameter("caja");
		System.out.println("caja................="+caja);

		if(mode==null) mode="add";
		if(fp==null) fp="";
		if(fg==null) fg="";
		if(tipo==null) tipo="";
		if(artType==null) artType="";
		if(caja==null) caja="";
%>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
			<tr>
				<td width="99%">
					<table align="center" width="100%" cellpadding="5" cellspacing="1" class=" TableTopBorder  TableBottomBorder">
					<tr class="">
						<td align="left" class="Text13">SubTotal(E)<input type="text" name="subtotal_exe" id="subtotal_exe" value="0.00" class="Text13 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0"></td>
						<td align="left" class="Text13">Desc.(E)<input type="text" name="descuento_exe" id="descuento_exe" value="0.00" class="Text13 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0"></td>
						<td align="left" class="Text13">&nbsp;</td>
							<input type="hidden" id="aplicadoDisplay" name="aplicadoDisplay" value="0">
						
						<td align="left" class="Text13">SubTotal(No E)<input type="text" name="subtotal_no_exe" id="subtotal_no_exe" value="0.00" class="Text13 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0"></td>
						<td align="left" class="Text13">Desc.(No E)<input type="text" name="descuento_no_exe" id="descuento_no_exe" value="0.00" class="Text13 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0"></td>
						<td align="left" class="Text13">ITBM<input type="text" name="itbm" id="itbm" value="0.00" class="Text13 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0"></td>
						<td align="left" class=" Text13">Total<input type="text" name="total" id="total" value="0.00" onChange="javascript:checkCredit();" class="Text13 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0" readOnly></td>
						<td align="left" class=" Text13">Pago<input type="text" name="pagoTotal" id="pagoTotal" value="0.00" class="Text13 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0" readOnly></td>
						<td align="left" class=" Text13">Cambio<input type="text" name="porAplicar" id="porAplicar" value="0.00" class="Text13 FormDataObjectEnabled" style="text-align:right;" size="10" maxLength="17.0" readOnly></td>
					</tr>
					<tr class="">
						<td colspan="9" class="TextLabel" align="center"><input type="button"  value="Cobrar" class="btn btn-primary btn-md" onClick="javascript:addFormaPago();" ></input>
						<%if(caja==null || caja.equals("null") || caja.equals("")){} else {%><input class="btn btn-success btn-md" type="button" name="save" id="save" value="Guardar" onClick="javascript:doSubmit(this.value)"></input>
						<%}%>
						<input class="btn btn-danger btn-md" type="button" name="cancel" id="cancel" value="Cancelar" onClick="javascript:window.location='../pos/facturar_touch.jsp?cds=<%=cds%>&familia=<%=familia%>&almacen=<%=almacen%>&tipo_pos=<%=tipo_pos%>&artType=<%=artType%>&tipo=<%=tipo%>&caja=<%=caja%>'"></input>
						<input type="button" name="btn2win" id="btn2win" value="Display" class="btn btn-primary btn-md" onClick="javascript:openSecondWindow();" ></input>
						
						</td>
					</tr>
					</table>
				</td>
				
			</tr>
		</table>
	</td>
</tr>
</table>
