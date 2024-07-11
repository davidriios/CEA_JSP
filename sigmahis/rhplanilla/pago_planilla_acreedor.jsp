<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoTot = new CommonDataObject();
String sql = "";
String acrId = request.getParameter("acrId");
String cod = request.getParameter("cod"); 
String num = request.getParameter("num"); 
String anio = request.getParameter("anio");
String id = request.getParameter("id");  

if (acrId == null || cod == null) throw new Exception("El empleado no es válido. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select  'N', da.cod_acreedor as codigo, ac.nombre nombre_ac, decode(da.provincia,0,' ',00,' ',11,'B',12,'C',da.provincia)||rpad(decode(da.sigla,'00','  ','0','  ',da.sigla),2,' ')||'-'||lpad(to_char(da.tomo),3,'0')||'-'|| lpad(to_char(da.asiento),5,'0') cedula, e.primer_nombre||' '||e.primer_apellido||' '||decode(e.sexo,'F',decode(e.apellido_casada, null,e.segundo_apellido,'DE '||e.apellido_casada),'M',e.segundo_apellido) nombre_empleado, pa.da_anio,pa.da_cod_planilla, pa.da_num_planilla, p.nombre nombre_planilla, e.num_empleado, d.num_documento,d.saldo, to_char(sum(da.monto),'999,999,990.00') monto_total, decode(nvl(ac.forma_pago,1),'1','Ck.','2','ACH') as pagar from tbl_pla_planilla p, tbl_pla_empleado e, tbl_pla_acreedor ac, tbl_pla_descuento d, tbl_pla_pago_acreedor pa, tbl_pla_descuento_aplicado da where ac.cod_acreedor = da.cod_acreedor and ac.compania = da.cod_compania and p.cod_planilla = pa.da_cod_planilla and p.compania = pa.cod_compania and pa.da_anio = da.anio and pa.da_cod_planilla = da.cod_planilla and pa.da_num_planilla = da.num_planilla and pa.cod_acreedor = da.cod_acreedor and pa.cod_grupo  is null and da.cod_grupo <> 18 and    e.provincia = da.provincia and e.sigla = da.sigla and e.tomo = da.tomo and e.asiento = da.asiento and e.compania = da.cod_compania and d.provincia = da.provincia and d.sigla = da.sigla and d.tomo = da.tomo and d.asiento = da.asiento and d.cod_compania = da.cod_compania and d.num_descuento = da.num_descuento and da.cod_compania = "+(String) session.getAttribute("_companyId")+" and pa.anio = "+anio+" and pa.num_planilla = "+num+" and pa.cod_planilla ="+cod+" and pa.cod_compania = "+(String) session.getAttribute("_companyId")+" and pa.cod_acreedor = "+acrId+" group by 'N',da.cod_acreedor, ac.nombre, decode(da.provincia, 0,' ',00,' ',11,'B',12,'C',da.provincia)||rpad(decode(da.sigla,'00','  ','0','  ',da.sigla),2,' ')||'-'||lpad(to_char(da.tomo),3,'0')||'-'|| lpad(to_char(da.asiento),5,'0'), e.primer_nombre||' '||e.primer_apellido||' '||decode(e.sexo,'F',decode(e.apellido_casada,null,e.segundo_apellido,'DE '||e.apellido_casada),'M',e.segundo_apellido), pa.da_anio,pa.da_cod_planilla,pa.da_num_planilla,p.nombre,e.num_empleado, d.num_documento, d.saldo, decode(nvl(ac.forma_pago,1),'1','Ck.','2','ACH')  having   sum(da.monto) <> 0"; 
	
	al = SQLMgr.getDataList(sql);
	
	
	CommonDataObject cdTot = SQLMgr.getData("select to_char(sum(da.monto),'999,999,990.00') total from tbl_pla_planilla p, tbl_pla_empleado e, tbl_pla_acreedor ac, tbl_pla_descuento d, tbl_pla_pago_acreedor pa, tbl_pla_descuento_aplicado da where ac.cod_acreedor = da.cod_acreedor and ac.compania = da.cod_compania and p.cod_planilla = pa.da_cod_planilla and p.compania = pa.cod_compania and pa.da_anio = da.anio and pa.da_cod_planilla = da.cod_planilla and pa.da_num_planilla = da.num_planilla and pa.cod_acreedor = da.cod_acreedor and pa.cod_grupo  is null and da.cod_grupo <> 18 and    e.provincia = da.provincia and e.sigla = da.sigla and e.tomo = da.tomo and e.asiento = da.asiento and e.compania = da.cod_compania and d.provincia = da.provincia and d.sigla = da.sigla and d.tomo = da.tomo and d.asiento = da.asiento and d.cod_compania = da.cod_compania and d.num_descuento = da.num_descuento and da.cod_compania = "+(String) session.getAttribute("_companyId")+" and pa.anio = "+anio+" and pa.num_planilla = "+num+" and pa.cod_planilla ="+cod+" and pa.cod_acreedor = "+acrId+" and pa.cod_compania = da.cod_compania");
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Pago a Empleados - '+document.title;


function winClose()
{
parent.SelectSlide('drs<%=id%>','list','clear')
parent.hidePopWin(true);
}


function printList(acrId,cod,anio,num)
{
	abrir_ventana('../rhplanilla/print_list_comp_pago_acr.jsp?acrId='+acrId+'&cod='+cod+'&anio='+anio+'&num='+num);
 
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - PAGO DE PLANILLA DE ACREEDORES "></jsp:param>
 <jsp:param name="title" value="COMPROBANTE DE PAGO"></jsp:param>
  <jsp:param name="displayCompany" value="y"></jsp:param>
  <jsp:param name="displayLineEffect" value="n"></jsp:param>
  <jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>






<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode","")%>
<%=fb.hidden("seccion","")%>
<%=fb.hidden("size","")%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("acrId",acrId)%>
<%=fb.hidden("cod",cod)%>
<%=fb.hidden("num",cod)%>
<%=fb.hidden("anio",anio)%>


<table width="100%" cellpadding="1" cellspacing="1">
 
  <tr>
    <td align="right" colspan="7">&nbsp;
        <%
//if (SecMgr.checkAccess(session.getId(),"0"))
//{
%>
        <a href="javascript:printList('<%=acrId%>','<%=cod%>','<%=anio%>','<%=num%>')" class="Link00">[ Imprimir Comprobante ]</a>
        <%
//}
%>    </td>
  </tr>
	
  <%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";						
%>
<% if(i == 0) { 
double totDesc = 0.00;
%>
<tr align="center" class="TextHeader">
    <td width="10%">&nbsp;</td>
	<td width="15%">&nbsp;</td>
    <td width="45%" align="center"><%=cdo.getColValue("nombre_planilla")%></td>
	<td width="15%">&nbsp;</td>
    <td width="15%">&nbsp;</td>
  </tr>
  
  <tr align="center" class="TextHeader">
    <td colspan="2"> Cod. Acreedor &nbsp; <%=cdo.getColValue("codigo")%></td>
    <td colspan="1" align="center"><%=cdo.getColValue("nombre_ac")%></td>
    <td colspan="2"> Forma de Pago :&nbsp;<%=cdo.getColValue("pagar")%></td>
  </tr>
  
    <tr align="center" class="TextHeader">
    <td colspan="5" align="center">Detalle </td>
    </tr>
  
  <tr align="center" class="TextHeader">
    <td>No. Emp. </td>
    <td>Cédula</td>
	<td align="left">Nombre del Empleado </td>
    <td>No. Doc.</td>
	<td>Monto</td>
  </tr>
	<% 	} %>
  
  <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
  <td align="left"> <%=cdo.getColValue("num_empleado")%></td>
    <td><%=cdo.getColValue("cedula")%></td>
	<td><%=cdo.getColValue("nombre_empleado")%></td>
    <td> <%=cdo.getColValue("num_documento")%></td>
	<td align="right"><%=cdo.getColValue("monto_total")%></td>
</tr>
  <%
	//totDesc += Double.parseDouble(cdo.getColValue("monto_total"));
		}
%>

 <tr align="center" class="TextHeader">
    <td colspan="4" align="right">Total por Acreedor : </td>
	 <td align="right"><%=cdTot.getColValue("total")%> </td>
    </tr>
   <tr align="center" class="TextHeader">
    <td colspan="4" align="right">Total de Registros : </td>
	 <td align="right"><%=al.size()%> </td>
    </tr>

</table>
<%=fb.formEnd(true)%>

</body>
</html>
<%
}//GET
%>
