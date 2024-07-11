<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iAseg" scope="session" class="java.util.Hashtable" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String appendFilter = "";
String mode = request.getParameter("mode");
String codigo = request.getParameter("codigo");

String key = "";

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{

if(codigo != null)
{
	sql="select e.nombre as emp_nombre,m.PRIMER_NOMBRE||' '||m.SEGUNDO_NOMBRE||' '||DECODE(m.APELLIDO_DE_CASADA,NULL,m.PRIMER_APELLIDO||' '||m.SEGUNDO_APELLIDO,m.APELLIDO_DE_CASADA)as pac_nombre,decode(f.facturar_a,'P', 'PACIENTE', 'E','EMPRESA', 'O','OTROS') as fact_a, f.codigo,f.facturar_a, to_char(f.fecha,'dd/mm/yyyy')fecha , f.monto_total, f.admi_secuencia admision,to_char(f.admi_fecha_nacimiento,'dd/mm/yyyy') as fecha_nacimiento,f.admi_codigo_paciente as paciente, f.numero_factura, f.pac_id, coalesce(e.nombre, m.PRIMER_NOMBRE||' '||m.SEGUNDO_NOMBRE||''||DECODE(m.APELLIDO_DE_CASADA,NULL,m.PRIMER_APELLIDO||' '||m.SEGUNDO_APELLIDO,m.APELLIDO_DE_CASADA))as descripcion, m.PROVINCIA||'-'||m.SIGLA||'-'||m.TOMO||'-'||m.ASIENTO||'-'||m.D_CEDULA cedula,f.estatus from tbl_fac_factura f,tbl_adm_empresa e,tbl_adm_paciente m where f.cod_empresa= e.codigo(+) and f.pac_id= m.pac_id(+) and  f.estatus in('P','C') and f.compania = "+(String) session.getAttribute("_companyId") +" and f.facturar_a in ('P','E') and f.codigo = '"+codigo+"' order by f.fecha, f.facturar_a desc";
		cdo = SQLMgr.getData(sql);		
		if (cdo == null)
	  {
			cdo = new CommonDataObject();
			cdo.addColValue("estatus","");
		}
	
}else 
{
	cdo = new CommonDataObject();
	cdo.addColValue("estatus","");
}



System.out.println("codigo = "+codigo);
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Facturacion - Cambiar Estatus Facturas- "+document.title;


function doAction()
{
  //setHeight('secciones',document.body.scrollHeight);
}
function estado()
{
var codigo = eval('document.form0.codigo').value ;
var compania = '<%=(String) session.getAttribute("_companyId")%>';

var estatus = '',estado;
var ubic = '';

if(document.form0.status[0].checked)
estatus = 'P';
else if(document.form0.status[1].checked)
estatus = 'C';
else estatus = '';


if(estatus != '' && codigo !='')
{
		if(estatus == "P")
		{
			estado ='C';
			ubic = 'COBROS';
		}
		else if(estatus == "C")
		{
			estado ='P';
			ubic = 'ANALISIS';
		}
		if(confirm('Desea Cambiar el Estatus de la Factura'))
		{
		
		if(executeDB('<%=request.getContextPath()%>','update tbl_fac_factura set estatus = \''+estado+'\', ubicacion = \''+ubic+'\' where codigo = \''+codigo+'\' and compania ='+compania,''))
						{
							CBMSG.warning('Estatus Cambiado!');
							window.location = '../facturacion/fact_cambiar_estatus.jsp?codigo='+codigo;
						}
		}
}//if estatus != ''
else
{
alert('Codigo o Estatus de la Factura Invalido. Verifique ');


}
}
function buscaF()
{
	//sel_facturas.jsp
		abrir_ventana2('../facturacion/sel_facturas.jsp');

}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>

<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="FACTURACION - CAMBIAR ESTATUS FACTURA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="1">
<tr>
         <td width="100%" class="TableBorder">
				 <table align="center"  width="100%" cellpadding="1" cellspacing="0">
    <tr>
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("action","")%>
<%=fb.hidden("pac_id","")%>					
					
<td>
            <table width="100%" cellpadding="1" cellspacing="1" align="center">
						<tr class="TextRow01" align="center">
							<td colspan="5">&nbsp;</td>
						</tr>  
						<tr class="TextHeader">
							<td colspan="5"><cellbytelabel>Cambiar Estatus a Facturas</cellbytelabel></td>
						</tr>
						<tr class="TextRow01">
							<td width="20%" align="right"><cellbytelabel>Fecha Nacimiento</cellbytelabel></td>
							<td width="20%"><%=fb.textBox("fecha_nacimiento",cdo.getColValue("fecha_nacimiento"),false,false,true,15,"Text10",null,null)%>	</td>
							<td width="20%"><cellbytelabel>Paciente</cellbytelabel><%=fb.textBox("codPac",cdo.getColValue("paciente"),false,false,true,15,"Text10",null,null)%>	</td>
							<td width="20%"><cellbytelabel>Admisi&oacute;n</cellbytelabel><%=fb.textBox("admision",cdo.getColValue("admision"),false,false,true,15,"Text10",null,null)%>	</td>
							<td width="20%"><cellbytelabel>C&eacute;dula</cellbytelabel><%=fb.textBox("cedula",cdo.getColValue("cedula"),false,false,true,15,"Text10",null,null)%>	</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Nombre</cellbytelabel></td>
							<td colspan="3"><%=fb.textBox("nombre",cdo.getColValue("pac_nombre"),false,false,true,60,"Text10",null,null)%>	</td>
							<td><cellbytelabel>Fecha</cellbytelabel><%=fb.textBox("fecha",cdo.getColValue("fecha"),false,false,true,15,"Text10",null,null)%>	</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Gran Total</cellbytelabel></td>
							<td><%=fb.textBox("total",cdo.getColValue("monto_total"),false,false,true,15,"Text10",null,null)%>	</td>
							<td rowspan="2" align="right"><cellbytelabel>Estatus</cellbytelabel></td>
							<td colspan="2" rowspan="2"><%=fb.radio("status","P",(cdo.getColValue("estatus").trim().equals("P")),true,false,null,null,"onClick=\"javascript:actualizar('P')\"")%>Pendiente<br><%=fb.radio("status","C",(cdo.getColValue("estatus").trim().equals("C")),true,false,null,null,"onClick=\"javascript:actualizar('C')\"")%><cellbytelabel>Cancelada</cellbytelabel>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Factura No</cellbytelabel>.</td>
							<td><%=fb.textBox("codigo",cdo.getColValue("codigo"),true,false,true,15,"Text10",null,null)%>
							<%=fb.button("buscar","...",false,false,"","","onClick=\"javascript:buscaF()\"","Buscar Factura")%> 	</td>
						</tr>
						<tr class="TextRow01">
							<td align="center" colspan="5">
							<%=fb.button("actualizar","Actualizar",false,false,"","","onClick=\"javascript:estado()\"","Cambiar Estatus")%> 	</td>
						</tr>
            </table>
 <%=fb.formEnd(true)%>
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
