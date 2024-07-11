<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
/**
======================================================================================================================================================
FORMA								MENU																																				NOMBRE EN FORMA
INV950128						INVENTARIO\TRANSACCIONES\CODIGOS AXA.																				ENLACE DEL CODIGO DEL MEDICAMENTO CON LOS CODIGOS DE AXA.
======================================================================================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
CommonDataObject cdoSI = new CommonDataObject();

String change = request.getParameter("change");
String key = "";
String sql = "", appendFilter = "";
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String type = request.getParameter("type");
String id_beneficiario = request.getParameter("id_beneficiario");
String fechaini = request.getParameter("fechaini");
String fechafin = request.getParameter("fechafin");
if(fechaini == null) fechaini = "";
if(fechafin == null) fechafin = "";
boolean viewMode = false;
int lineNo = 0;
String compania = (String)session.getAttribute("_companyId");
CommonDataObject cdoT = new CommonDataObject();

if(mode == null) mode = "add";
if(fp==null) fp="cat_ctas";
if(mode.equals("view")) viewMode = true;
if(fechaini==null) fechaini="";
if(fechafin==null) fechafin="";
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(!fechaini.equals("") && !fechafin.equals("")) appendFilter = " and trunc(fecha_documento) between to_date('"+fechaini+"', 'dd/mm/yyyy') and to_date('"+fechafin+"', 'dd/mm/yyyy')";
	sbSql.append("select nvl(sum(nvl (debito, 0) - nvl(credito, 0)),0) saldo_inicial from vw_pm_mov_clte where compania = ");
	sbSql.append(compania);
	sbSql.append(" and id_beneficiario = '");
	sbSql.append(id_beneficiario);
	sbSql.append("'");
	if(!fechaini.equals("")){
	sbSql.append(" and trunc(fecha_documento) < to_date('");
	sbSql.append(fechaini);
	sbSql.append("','dd/mm/yyyy')");}
	
	cdoSI = SQLMgr.getData(sbSql.toString());
	sbSql = new StringBuffer();
	sbSql.append("select a.tipo_doc, a.tipo_docto, a.compania, a.id_beneficiario, a.anio, to_char(a.fecha_documento, 'dd/mm/yyyy') fecha, a.numero_documento, a.numero_factura, a.credito, a.debito, decode(a.tipo_doc, 'FACT', 'FACTURA', 'ND', 'NOTA DE DEBITO', 'NC', 'NOTA DE CREDITO', 'PAGO', 'PAGO') tipo_doc_desc, a.estado, a.fecha_documento f_doc, a.nombre_cliente, a.num_orden_pago from vw_pm_mov_clte a where a.compania = ");
	sbSql.append(compania);
	sbSql.append(" and a.id_beneficiario = '");
	sbSql.append(id_beneficiario);
	sbSql.append("' ");
	sbSql.append(appendFilter);
	sql=sbSql.toString();
	sbSql.append(" order by a.fecha_documento ");

	al = SQLMgr.getDataList(sbSql.toString());

	sql +=appendFilter;
	cdoT = SQLMgr.getData("select nvl(sum(debito), 0) debito, nvl(sum(credito), 0) credito from ("+sql+")");
		
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
function doAction(){
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function ver(no, anio, tipo, tipo_docto)
{	
	if(tipo=='FACT' || tipo=='NC') abrir_ventana('../planmedico/reg_liquidacion_reclamo.jsp?mode=view&codigo='+no+'&tipotrx='+tipo_docto);	
	else if(tipo=='PAGO') abrir_ventana('../cxp/cheque.jsp?mode=view&num_orden_pago='+no+'&anio='+anio+'&fg=CSOP');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" bgcolor="#fafbfa" onLoad="javascript:doAction()">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("clearHT","")%>
<table width="100%" align="center"  cellpadding="1" cellspacing="1">
  <tr class="TextHeaderOver">
  	<td width="12%">
      <table width="100%" align="center"  cellpadding="1" cellspacing="1" bordercolor="#FFFFFF">
        <tr class="TextHeader02" height="21">
          <td align="center" width="10%"><cellbytelabel>Tipo Doc</cellbytelabel>.</td>
          <td align="center" width="12%"><cellbytelabel>Descripci&oacute;n</cellbytelabel></td>
          <td align="center" width="15%"><cellbytelabel>No. Doc</cellbytelabel>.</td>
          <td align="center" width="15%"><cellbytelabel>Factura/Doc.</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Fecha</cellbytelabel></td>
          <td align="center" width="14%"><cellbytelabel>D&eacute;bito</cellbytelabel></td>
          <td align="center" width="14%"><cellbytelabel>Cr&eacute;dito</cellbytelabel></td>
          <td align="center" width="10%"><cellbytelabel>Saldo</cellbytelabel></td>
        </tr>
        <tr class="TextHeader01" align="center">
          <td align="right" colspan="5"><cellbytelabel>Saldo Inicial</cellbytelabel></td>
          <td align="right">&nbsp;</td>
          <td align="right">&nbsp;</td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdoSI.getColValue("saldo_inicial"))%></td>
        </tr>
        <%
				double saldo = 0.00,totDbFg=0.00,totCrFg=0.00,saldoFg=0.00,totDbCre=0.00,totCrCre=0.00,saldoCre=0.00;
				String groupBy="",groupByDesc="";
				boolean printTotal =false;
				if(cdoSI.getColValue("saldo_inicial") != null && !cdoSI.getColValue("saldo_inicial").equals("")) saldo = Double.parseDouble(cdoSI.getColValue("saldo_inicial"));
				for (int i=0; i<al.size(); i++){
          CommonDataObject cdo = (CommonDataObject) al.get(i);

          String color = "";
          if (i%2 == 0) color = "TextRow02";
          else color = "TextRow01";
          boolean readonly = true;
					/*if(cdo.getColValue("tipo_doc").equals("FACT") && cdo.getColValue("estado").equals("A")){
						cdo.addColValue("tipo_doc_desc", cdo.getColValue("tipo_doc_desc") + " - "+CmnMgr.getFormattedDecimal(cdo.getColValue("debito")));
						cdo.addColValue("debito", "0");
					}*/
				
					
			totDbFg += Double.parseDouble(cdo.getColValue("debito"));
			totCrFg += Double.parseDouble(cdo.getColValue("credito"));	
			
			saldoFg += Double.parseDouble(cdo.getColValue("debito"));
			saldoFg -= Double.parseDouble(cdo.getColValue("credito"));
			saldo += Double.parseDouble(cdo.getColValue("debito"));
			saldo -= Double.parseDouble(cdo.getColValue("credito"));
			
		
		
		%>
        <tr class="<%=color%>" align="center" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
          <td align="center">
          <a href="javascript:ver('<%=(cdo.getColValue("tipo_doc").equals("PAGO")?cdo.getColValue("num_orden_pago"):cdo.getColValue("numero_documento"))%>','<%=cdo.getColValue("anio")%>','<%=cdo.getColValue("tipo_doc")%>','<%=cdo.getColValue("tipo_docto")%>')" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')"><%=cdo.getColValue("tipo_doc")%></a>
          </td>
          <td align="left"><%=cdo.getColValue("tipo_doc_desc")%></td>
          <td align="center"><%=cdo.getColValue("numero_documento")%></td>
          <td align="center"><%=cdo.getColValue("numero_factura")%></td>
          <td align="center"><%=cdo.getColValue("fecha")%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal((cdo.getColValue("tipo_doc").equals("FACT") && cdo.getColValue("estado").equals("A")?"0":cdo.getColValue("debito")))%></td>
          <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("credito"))%></td>
          <td align="right">
		   <%if(saldo <0){%><label class="<%=color%>"><label class="RedTextBold">&nbsp;&nbsp;
		  		<%=CmnMgr.getFormattedDecimal(saldo)%>  
		   	 &nbsp;&nbsp;</label></label><%}else{%>
			 
			 <%=CmnMgr.getFormattedDecimal(saldo)%>  
			 <%}%>
		  
					
          </td>
        </tr>
        <% 
				}
				%>
		<tr class="TextHeader02" align="center">
          <td align="right" colspan="5"><cellbytelabel>SALDO:</cellbytelabel></td>
          <td align="right">&nbsp;</td>
          <td align="right">&nbsp;</td>
          <td align="right"><%if(saldo <0){%><label class="TextHeader02"><label class="RedTextBold">&nbsp;&nbsp;
		  		<%=CmnMgr.getFormattedDecimal(saldo)%>  
		   	 &nbsp;&nbsp;</label></label><%}else{%>
			 
			 <%=CmnMgr.getFormattedDecimal(saldo)%>  
			 <%}%>
			 </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}%>