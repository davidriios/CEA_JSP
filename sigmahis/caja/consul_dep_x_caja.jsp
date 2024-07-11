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
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="OrdPagoMgr" scope="page" class="issi.cxp.OrdenPagoMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%
/**
==========================================================================================
FORMA CJA90041C CONSULTA DE DEPOSITOS POR CAJA
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
OrdPagoMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoT = new CommonDataObject();
String sql = "", key = "";
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String fp = request.getParameter("fp");
String fg = request.getParameter("fg");
String caja = request.getParameter("caja");
String fecha_desde = request.getParameter("fecha_desde");
String fecha_hasta = request.getParameter("fecha_hasta");
String appendFilter ="";
boolean viewMode = false;
int iconSize = 18;

if(caja==null) caja = "";
if(fecha_desde==null) fecha_desde = "";
if(fecha_hasta==null) fecha_hasta = "";

if(fg==null) fg = "";
if(fp==null) fp = "";

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	cdoT = SQLMgr.getData("select 0 mto_tot_tarjeta, 0 devoluc_tarj, 0 comision, 0 monto from dual");

	if(!caja.equals("")) appendFilter += " and a.caja = "+caja;
	if(!fecha_desde.equals("")) appendFilter += " and trunc(a.f_movimiento) >= to_date('"+fecha_desde+"', 'dd/mm/yyyy')";
	if(!fecha_hasta.equals("")) appendFilter += " and trunc(a.f_movimiento) <= to_date('"+fecha_hasta+"', 'dd/mm/yyyy')";

	if(!caja.equals("") || !fecha_desde.equals("") || !fecha_hasta.equals("")){
	sql = "select a.caja, a.turno, a.consecutivo_ag, (select nombre from where compania = a.compania and cod_banco = a.banco) banco_desc, a.cuenta_banco, to_char(a.f_movimiento, 'dd/mm/yyyy') f_movimiento, a.num_documento, c.descripcion tarjeta_desc, nvl(a.mto_tot_tarjeta, 0) mto_tot_tarjeta, nvl(a.devoluc_tarj, 0) devoluc_tarj, nvl(a.comision, 0) comision, nvl(a.monto, 0) monto, to_char(a.fecha_creacion, 'dd/mm/yyyy hh12:mi am') fecha_creacion, to_char(a.fecha_modificacion, 'dd/mm/yyyy hh12:mi am') fecha_modificacion, a.usuario_creacion, a.usuario_modificacion, a.observacion from tbl_con_movim_bancario a, tbl_cja_tipo_tarjeta c where a.tipo_tarjeta = c.codigo(+) and a.compania = "+(String) session.getAttribute("_companyId") + appendFilter +" /*and a.estado_trans = 'T' and a.estado_dep = 'DT'*/";
	al = SQLMgr.getDataList(sql);
	sql = "select nvl(sum(a.mto_tot_tarjeta), 0) mto_tot_tarjeta, nvl(sum(a.devoluc_tarj), 0) devoluc_tarj, nvl(sum(a.comision), 0) comision, nvl(sum(a.monto), 0) monto from tbl_con_movim_bancario a where a.compania = "+(String) session.getAttribute("_companyId") + appendFilter +" /*and a.estado_trans = 'T' and a.estado_dep = 'DT'*/";
	cdoT = SQLMgr.getData(sql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Caja- '+document.title;

function doAction(){
	if(document.depositos.rb) setDetValues();
}

function doSubmit(value){
}

function reloadPage(){
	var caja = document.depositos.caja.value;
	var fecha_desde = document.depositos.fecha_desde.value;
	var fecha_hasta = document.depositos.fecha_hasta.value;
	window.location = '../caja/consul_dep_x_caja.jsp?caja='+caja+'&fecha_desde='+fecha_desde+'&fecha_hasta='+fecha_hasta;
}

function chkRB(i){
	checkRadioButton(document.depositos.rb, i);
	setDetValues();
}

function setDetValues(){
	var i = 	getRadioButtonValue(document.depositos.rb);
	document.depositos.observacion.value = 	eval('document.depositos.observacion'+i).value;
	document.depositos.usuario_creacion.value = 	eval('document.depositos.usuario_creacion'+i).value;
	document.depositos.fecha_creacion.value = 	eval('document.depositos.fecha_creacion'+i).value;
	document.depositos.usuario_modificacion.value = 	eval('document.depositos.usuario_modificacion'+i).value;
	document.depositos.fecha_modificacion.value = 	eval('document.depositos.fecha_modificacion'+i).value;
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="CONSULTA DE DEPOSITOS POR CAJA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
    	<table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <tr>
          <td>
          	<table align="center" width="99%" cellpadding="0" cellspacing="1">
              <%
							fb = new FormBean("depositos","","post");
							%>
              <%=fb.formStart(true)%> 
							<%=fb.hidden("mode",mode)%>
							<%=fb.hidden("errCode","")%> 
							<%=fb.hidden("errMsg","")%> 
							<%=fb.hidden("saveOption","")%> 
							<%=fb.hidden("clearHT","")%> 
							<%=fb.hidden("action","")%> 
							<%=fb.hidden("fg",fg)%>
              <tr class="TextPanel">
                <td colspan="6"><cellbytelabel>Consulta de Dep&oacute;sitos por Caja</cellbytelabel></td>
              </tr>
              <tr class="TextPanel">
                <td colspan="6"><cellbytelabel>Caja:</cellbytelabel>
								<%=fb.select(ConMgr.getConnection(),"select codigo, codigo ||' - ' || descripcion descripcion from tbl_cja_cajas where compania = "+(String) session.getAttribute("_companyId")+" order by descripcion asc","caja",caja,false,false,0,null,null,"","", "T")%>
                <cellbytelabel>Fecha</cellbytelabel>
                <jsp:include page="../common/calendar.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="2" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="fecha_desde"/>						
                <jsp:param name="valueOfTBox1" value="<%=fecha_desde%>" />
                <jsp:param name="nameOfTBox2" value="fecha_hasta"/>						
                <jsp:param name="valueOfTBox2" value="<%=fecha_hasta%>" />
                </jsp:include>
                <%=fb.button("ir","Ir",false,false,null,null,"onClick=\"javascript:reloadPage()\"")%>
                 </td>
              </tr>
              <tr class="">
              	<td colspan="6">
                <div id="list_opMain" width="100%" style="overflow:scroll;position:relative;height:340">
                <div id="list_op" width="100%" style="overflow;position:absolute">
                <table align="center" width="99%" cellpadding="0" cellspacing="1">
              <tr class="TextHeader02" >
                <td align="center" width="6%"><cellbytelabel>Caja</cellbytelabel></td>
                <td align="center" width="6%"><cellbytelabel>Turno</cellbytelabel></td>
                <td align="center" width="8%"><cellbytelabel>Consecutivo</cellbytelabel></td>
                <td align="center" width="12%"><cellbytelabel>Banco</cellbytelabel></td>
                <td align="center" width="13%"><cellbytelabel>Cuenta</cellbytelabel></td>
                <td align="center" width="7%"><cellbytelabel>Fecha Dep.</cellbytelabel></td>
                <td align="center" width="7%"><cellbytelabel># Voucher / Term.</cellbytelabel></td>
                <td align="center" width="8%">&nbsp;</td>
                <td align="center" width="8%"><cellbytelabel>Venta Bruta Tarjeta</cellbytelabel></td>
                <td align="center" width="8%"><cellbytelabel>Devol. Tarjeta</cellbytelabel></td>
                <td align="center" width="8%"><cellbytelabel>Comisi&oacute;n</cellbytelabel></td>
                <td align="center" width="8%"><cellbytelabel>Total Depositado</cellbytelabel></td>
                <td align="center" width="1%">&nbsp;</td>
              </tr>
              <%
							for (int i=0; i<al.size(); i++){
								CommonDataObject OP = (CommonDataObject) al.get(i);
								String color = "TextRow03";
								if (i % 2 == 0) color = "TextRow04";
						%>
							<%=fb.hidden("observacion"+i,OP.getColValue("observacion"))%>
							<%=fb.hidden("usuario_creacion"+i,OP.getColValue("usuario_creacion"))%>
							<%=fb.hidden("fecha_creacion"+i,OP.getColValue("fecha_creacion"))%>
							<%=fb.hidden("usuario_modificacion"+i,OP.getColValue("usuario_modificacion"))%>
							<%=fb.hidden("fecha_modificacion"+i,OP.getColValue("fecha_modificacion"))%>
              <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer" onClick="javascript:javascript:chkRB(<%=i%>);">
                <td align="center"><%=OP.getColValue("caja")%></td>
                <td align="center"><%=OP.getColValue("turno")%></td>
                <td align="center"><%=OP.getColValue("consecutivo_ag")%></td>
                <td align="center"><%=OP.getColValue("banco_desc")%></td>
                <td align="center"><%=OP.getColValue("cuenta_banco")%></td>
                <td align="center"><%=OP.getColValue("f_movimiento")%></td>
                <td align="center"><%=OP.getColValue("num_documento")%></td>
                <td align="center"><%=OP.getColValue("tarjeta_desc")%></td>
                <td align="right"><%=CmnMgr.getFormattedDecimal(OP.getColValue("mto_tot_tarjeta"))%>&nbsp;&nbsp;</td>
                <td align="right"><%=CmnMgr.getFormattedDecimal(OP.getColValue("devoluc_tarj"))%>&nbsp;&nbsp;</td>
                <td align="right"><%=CmnMgr.getFormattedDecimal(OP.getColValue("comision"))%>&nbsp;&nbsp;</td>
                <td align="right"><%=CmnMgr.getFormattedDecimal(OP.getColValue("monto"))%>&nbsp;&nbsp;</td>
                <td align="center" onClick="javascript:chkRB(<%=i%>);"><%=fb.radio("rb",""+i,(i==0?true:false),viewMode,false, "", "", "onClick=\"javascript:setDetValues()\"")%></td>
              </tr>
              <%}%>
              <%=fb.hidden("keySize",""+al.size())%>
              </table>
              </div>
              </div>
              </td></tr>
              <tr class="" >
                <td colspan="6">
                	<table align="center" width="99%" cellpadding="0" cellspacing="1">
                    <tr class="TextHeader02" >
                      <td align="right" width="65%"><cellbytelabel>Totales:</cellbytelabel></td>
                      <td align="right" width="8%"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("mto_tot_tarjeta"))%>&nbsp;&nbsp;</td>
                      <td align="right" width="8%"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("devoluc_tarj"))%>&nbsp;&nbsp;</td>
                      <td align="right" width="8%"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("comision"))%>&nbsp;&nbsp;</td>
                      <td align="right" width="8%"><%=CmnMgr.getFormattedDecimal(cdoT.getColValue("monto"))%>&nbsp;&nbsp;</td>
                      <td width="3%">&nbsp;</td>
                    </tr>
                  </table>
              	</td>
              </tr>
              <tr class="" >
                <td colspan="6">
                	<table align="center" width="99%" cellpadding="0" cellspacing="1">
                    <tr class="TextPanel" >
                      <td align="center"><cellbytelabel>Creado Por:</cellbytelabel><br>
											<%=fb.textBox("usuario_creacion","",false,false,true,10,"text10",null,"")%>
                      <%=fb.textBox("fecha_creacion","",false,false,true,18,"text10",null,"")%>
                      </td>
                      <td align="center"><cellbytelabel>Aprob. Sol.:</cellbytelabel><br>
											<%=fb.textBox("usuario_modificacion","",false,false,true,10,"text10",null,"")%>
                      <%=fb.textBox("fecha_modificacion","",false,false,true,18,"text10",null,"")%>
                      </td>
                      <td align="center"><cellbytelabel>Descripci&oacute;n del Dep&oacute;sito:</cellbytelabel><br>
											<%=fb.textBox("observacion","",false,false,true,50,"text10",null,"")%>
                      </td>
                    </tr>
                  </table>
              	</td>
              </tr>
              <tr>
                <td colspan="6">&nbsp;</td>
              </tr>
              <%=fb.formEnd(true)%>
              <!-- ================================   F O R M   E N D   H E R E   ================================ -->
            </table>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
%>
