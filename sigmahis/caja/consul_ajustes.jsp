<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.cxp.OrdenPago"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="OP" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="OrdPago" scope="session" class="issi.cxp.OrdenPago" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
OrdPagoMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
String change = request.getParameter("change");
String key = "";
String sql = "";
String mode = request.getParameter("mode");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String anio = request.getParameter("anio");
String codigo = request.getParameter("codigo");
String secuencia_pago = request.getParameter("secuencia_pago");

if(anio==null) anio = "";
if(codigo==null) codigo = "";
if(secuencia_pago==null) secuencia_pago = "";

int lineNo = 0;

boolean viewMode = false;
String type = request.getParameter("type");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(!codigo.equals("")){
		sql="select distinct a.referencia, a.nota_ajuste, a.tipo_ajuste, b.descripcion desc_ajuste, a.recibo, decode(a.tipo_doc,'F','FACTURA','R','RECIBO') tipo_doc, a.explicacion, to_char(a.fecha, 'dd/mm/yyyy') fecha, a.factura, decode(a.lado_mov, 'D', 'Debito', 'C', 'Credito') lado_mov, decode(a.tipo, 'H', a.medico, 'E', a.empresa, 'C', a.centro) codigo, decode(a.tipo, 'H', (select primer_apellido||' '||segundo_apellido||' '||apellido_de_casada ||' '||primer_nombre||' '||segundo_nombre from tbl_adm_medico where codigo = a.medico), 'E', (select nombre from tbl_adm_empresa where codigo = a.empresa), 'C', (select descripcion from tbl_cds_centro_servicio where codigo = a.centro)) descripcion, a.monto, a.usuario_creacion, a.usuario_modificacion, to_char(a.fecha_creacion, 'dd/mm/yyyy hh12:mi am') fecha_creacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy hh12:mi am') fecha_modificacion from vw_con_adjustment_gral a, tbl_fac_tipo_ajuste b where  a.tipo_ajuste = b.codigo and a.compania = b.compania and a.compania = "+(String) session.getAttribute("_companyId") + " and a.factura = '"+codigo+"' union select a.reference_id, a.doc_id, null tipo_ajuste, 'AJUSTE PRONTO PAGO' desc_ajuste, '' recibo,'FACTURA' tipo_doc, a.observations  explicacion, to_char(a.doc_date, 'dd/mm/yyyy') fecha,(select x.other3 from tbl_fac_trx x where x.doc_type = 'FAC' and x.doc_id = a.reference_id) factura, 'Credito' lado_mov,to_char(a.centro_servicio) codigo,(select descripcion from tbl_cds_centro_servicio where codigo = a.centro_servicio)  descripcion,a.net_amount monto, a.created_by usuario_creacion, a.modified_by usuario_modificacion, to_char(a.sys_date, 'dd/mm/yyyy hh12:mi am') fecha_creacion, to_char(a.modified_date, 'dd/mm/yyyy hh12:mi am') fecha_modificacion from tbl_fac_trx a where exists (select null from tbl_fac_trx x where x.other3 ='"+codigo+"' and x.doc_type = 'FAC' and x.doc_id = a.reference_id) and a.company_id = "+(String) session.getAttribute("_companyId") + " and a.doc_type in ('NDB', 'NCR') and a.status = 'O'";
		al = SQLMgr.getDataList(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function doAction()
{	
	if(document.form1.rb) setDetValues();
	if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}

function _doSubmit(valor){
	document.form1.action.value = valor;
	document.form1.clearHT.value = 'N';
	if(parent.doSubmit()) doSubmit();
}

function doSubmit(){
}

function chkRB(i){
	checkRadioButton(document.form1.rb, i);
	setDetValues();
}

function setDetValues(){
	var i = 	getRadioButtonValue(document.form1.rb);
	document.form1.tipo_ajuste.value = 	eval('document.form1.tipo_ajuste'+i).value;
	document.form1.tipo_ajuste_desc.value = 	eval('document.form1.desc_ajuste'+i).value;
	document.form1.tipo_doc.value = 	eval('document.form1.tipo_doc'+i).value;
	document.form1.recibo.value = 	eval('document.form1.recibo'+i).value;
	document.form1.explicacion.value = 	eval('document.form1.explicacion'+i).value;
	document.form1.usuario_creacion.value = 	eval('document.form1.usuario_creacion'+i).value;
	document.form1.fecha_creacion.value = 	eval('document.form1.fecha_creacion'+i).value;
	document.form1.usuario_modificacion.value = 	eval('document.form1.usuario_modificacion'+i).value;
	document.form1.fecha_modificacion.value = 	eval('document.form1.fecha_modificacion'+i).value;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%
fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%> 
<%=fb.hidden("mode",mode)%> 
<%=fb.hidden("baction","")%> 
<%=fb.hidden("fg",fg)%> 
<%=fb.hidden("anio",anio)%> 
<%=fb.hidden("clearHT","")%> 
<%=fb.hidden("action","")%> 

<%=fb.hidden("codigo","")%> 

<table width="100%" align="center">
  <tr>
    <td><table align="center" width="100%" cellpadding="0" cellspacing="1">
        <tr class="TextPanel">
          <td colspan="7"><cellbytelabel>Ajustes</cellbytelabel></td>
        </tr>
        <tr class="">
          <td colspan="6">
          <div id="list_opMain" width="100%" class="caja h300">
          <div id="list_op" width="100%" class="child">
	          <table align="center" width="99%" cellpadding="0" cellspacing="1">
              <tr class="TextHeader">
                <td width="10%" align="center"><cellbytelabel>No. Ref. F&iacute;sica</cellbytelabel></td>
                <td width="10%" align="center"><cellbytelabel>No. Ajuste Sistema</cellbytelabel></td>
                <td width="10%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
                <td width="15%" align="center"><cellbytelabel>Lado Mov.</cellbytelabel></td>
                <td width="43%" align="center" colspan="2">Decripci&oacute;n</cellbytelabel></td>
                <td width="10%" align="center"><cellbytelabel>Monto Ajustado</cellbytelabel></td>
                <td width="2%" align="center">&nbsp;</td>
             </tr>
              <%
              key = "";
              double monto_total = 0.00;
              for (int i=0; i<al.size(); i++){
                CommonDataObject cdo = (CommonDataObject) al.get(i);
                monto_total += Double.parseDouble(cdo.getColValue("monto"));
      
                String color = "TextRow02";
                if (i % 2 == 0) color = "TextRow01";
              %>
              <%=fb.hidden("tipo_ajuste"+i,cdo.getColValue("tipo_ajuste"))%> 
							<%=fb.hidden("desc_ajuste"+i,cdo.getColValue("desc_ajuste"))%>
							<%=fb.hidden("tipo_doc"+i,cdo.getColValue("tipo_doc"))%>
							<%=fb.hidden("recibo"+i,cdo.getColValue("recibo"))%>
							<%=fb.hidden("explicacion"+i,cdo.getColValue("explicacion"))%>
							<%=fb.hidden("usuario_creacion"+i,cdo.getColValue("usuario_creacion"))%>
							<%=fb.hidden("fecha_creacion"+i,cdo.getColValue("fecha_creacion"))%>
							<%=fb.hidden("usuario_modificacion"+i,cdo.getColValue("usuario_modificacion"))%>
							<%=fb.hidden("fecha_modificacion"+i,cdo.getColValue("fecha_modificacion"))%>
              <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" onClick="javascript:javascript:chkRB(<%=i%>);">
                <td align="center"><%=cdo.getColValue("referencia")%></td>
                <td align="center"><%=cdo.getColValue("nota_ajuste")%></td>
                <td align="center"><%=cdo.getColValue("fecha")%></td>
                <td align="center"><%=cdo.getColValue("lado_mov")%></td>
                <td align="center"><%=cdo.getColValue("codigo")%></td>
                <td align="center"><%=cdo.getColValue("descripcion")%></td>
                <td align="right"><%=CmnMgr.getFormattedDecimal(cdo.getColValue("monto"))%>&nbsp;&nbsp; </td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false, "", "", "onClick=\"javascript:setDetValues()\"")%></td>
              </tr>
        <%
				}
				%>
              </table>
              </div>
              </div>
          </td>
        </tr>
        <tr>
          <td colspan="6">
          	<table align="center" width="99%" cellpadding="0" cellspacing="1">
            	<tr class="TextHeader">
                <td><cellbytelabel>Tipo Ajuste</cellbytelabel><br>
                <%=fb.textBox("tipo_ajuste","",false,false,true,15,"text10",null,"")%>
                <%=fb.textBox("tipo_ajuste_desc","",false,false,true,50,"text10",null,"")%>
                </td>
                <td><cellbytelabel>Doc. que afecta</cellbytelabel><br>
                <%=fb.textBox("tipo_doc","",false,false,true,20,"text10",null,"")%>
                </td>
                <td><cellbytelabel>No. Recibo</cellbytelabel><br>
                <%=fb.textBox("recibo","",false,false,true,20,"text10",null,"")%>
                </td>
             	</tr>
            	<tr class="TextHeader">
                <td colspan="3"><cellbytelabel>Explicaci&oacute;n del Ajuste</cellbytelabel><br>
                <%=fb.textBox("explicacion","",false,false,true,90,"text10",null,"")%>
                </td>
             	</tr>
            	<tr class="TextHeader">
                <td><cellbytelabel>Usuario Creaci&oacute;n:</cellbytelabel>
                <%=fb.textBox("usuario_creacion","",false,false,true,20,"text10",null,"")%>
                <%=fb.textBox("fecha_creacion","",false,false,true,20,"text10",null,"")%>
                </td>
                <td colspan="2"><cellbytelabel>Usuario Modificaci&oacute;n:</cellbytelabel>
                <%=fb.textBox("usuario_modificacion","",false,false,true,20,"text10",null,"")%>
                <%=fb.textBox("fecha_modificacion","",false,false,true,20,"text10",null,"")%>
                </td>
             	</tr>
          	</table>
          </td>
        </tr>
        <%=fb.hidden("keySize",""+al.size())%> 
      </table></td>
  </tr>
</table>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
</body>
</html>
<%
}//GET 
%>

