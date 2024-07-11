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

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String sql = "";
String pacId = request.getParameter("pacId");
String secuencia = request.getParameter("secuencia");
String id = request.getParameter("id");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String appendFilter = "";
String desc =request.getParameter("desc");
String tipoOrden = request.getParameter("tipoOrden");
String idOrden = request.getParameter("idOrden");
String extraParam = "";
	
if (tipoOrden == null ) tipoOrden = ""; 
if (idOrden == null ) idOrden = "";

if ( !tipoOrden.equals("") ) {
   appendFilter += " and a.tipo_orden = "+tipoOrden; 
   extraParam += "&tipoOrden="+tipoOrden;
}
if ( !idOrden.equals("") ) {
   appendFilter += " and a.orden_med in ( "+idOrden+" )";
   extraParam += "&idOrden="+idOrden;
}

if (pacId == null || secuencia == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

if (request.getMethod().equalsIgnoreCase("GET"))
{
	sql = "select a.secuencia as secuenciaCorte, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi am') as fechaSolicitud, t.descripcion as tipoOrden, decode(a.tipo_orden,3,'DIETA - '||x.nombre||'  '||decode(a.nombre,null,' ',' - '||a.nombre), 1, a.nombre||decode(a.prioridad,'H','  --> HOY  '||to_char(a.fecha_orden,'dd-mm-yyyy'),'U',' - HOY URGENTE  '||to_char(a.fecha_orden,'dd-mm-yyyy'),'M','  --> MAÑANA '||to_char(a.fecha_orden,'dd-mm-yyyy'),'O','  --> '||to_char(a.fecha_orden,'dd-mm-yyyy')),  7,d.descripcion||' - '||a.observacion,a.nombre) as nombre, a.ejecutado, a.tipo_orden, a.codigo, a.orden_med, a.estado_orden, to_char(a.fecha_fin,'dd/mm/yyyy hh12:mi am') as fecha_fin, nvl(to_char(a.fecha_suspencion,'dd/mm/yyyy hh12:mi am'),' ') as fechaSuspencion, nvl(a.cod_salida,0) as cod_salida,nvl(a.confirmado,'N') as confirmado,nvl(f.observacion,f.observacion_ap) as comentario_r ,'U' as action,usuario_conf,nvl(to_char(a.fecha_conf,'dd/mm/yyyy hh12:mi am'),' ') as fecha_conf from tbl_sal_detalle_orden_med a, tbl_sal_tipo_orden_med t, (select b.codigo||'-'||c.codigo as codigo, b.descripcion||decode(c.descripcion,null,'',' - '||c.descripcion) as nombre from tbl_cds_tipo_dieta b, tbl_cds_subtipo_dieta c where b.codigo=c.cod_tipo_dieta union all select t.codigo||'-', t.descripcion from tbl_cds_tipo_dieta t ) x, tbl_sal_orden_salida d, tbl_int_orden_farmacia f,tbl_adm_admision z where z.pac_id=a.pac_id and z.secuencia=a.secuencia and z.pac_id="+pacId+" and z.adm_root="+secuencia+" and a.tipo_orden=t.codigo(+) /*and ((a.omitir_orden='N' and a.estado_orden='A') or (a.ejecutado='N' and a.estado_orden='S'))*/ and a.tipo_dieta||'-'||a.cod_tipo_dieta=x.codigo(+) and a.cod_salida=d.codigo(+) "+appendFilter+"  and a.pac_id = f.pac_id and a.secuencia = nvl(f.adm_cargo,f.admision)/*admision*/ and a.tipo_orden = f.tipo_orden and a.orden_med = f.orden_med and a.codigo = f.codigo and f.seguir_despachando='N' and  f.other1 = 0  order by a.fecha_creacion desc";
	/*and (to_date(to_char(a.fecha_orden,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy') or (to_date(to_char(a.fecha_fin,'dd/mm/yyyy'),'dd/mm/yyyy') >= to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy')))**/
	al = SQLMgr.getDataList(sql);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<script language="javascript">
document.title = 'Listado de Ordenes Médicas Rechazadas - '+document.title;
function printList(){abrir_ventana('../expediente/print_list_orden_rechazada.jsp?pacId=<%=pacId%>&noAdmision=<%=secuencia%><%=extraParam%>');}
function doAction(){}
 
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="LISTADO DE ORDENES MEDICAS RECHAZADAS"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>
<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode","")%>
<%=fb.hidden("seccion","")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("secuencia",secuencia)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("desc",desc)%>

<tr>
	<td width="20%">&nbsp;</td>
	<td width="60%" align="center"><cellbytelabel id="1">Total Registro(s)</cellbytelabel> <%=al.size()%></td>
	<td width="20%" align="right">
		&nbsp;
		<authtype type='50'><%=fb.button("print","Imprimir",true,false,"Text10",null,"onClick=\"javascript:printList()\"")%></authtype>		 
		<%=fb.submit("save","Guardar",true,!(UserDet.getUserProfile().contains("0") || UserDet.getRefType().trim().equalsIgnoreCase("M") || UserDet.getXtra5().trim().equalsIgnoreCase("S")),"Text10",null,null)%>
	</td>
</tr>
<tr>
	<td colspan="3">
		<div id="ordenesMain" width="100%" class="exp h260">
		<div id="ordenes" width="98%" class="child">
		<table width="100%" cellpadding="1" cellspacing="1">
		<tr align="center" class="TextHeader">
			<td width="13%"><cellbytelabel id="2">Fecha de Solicitud</cellbytelabel></td>
			<td width="12%"><cellbytelabel id="3">Tipo Orden</cellbytelabel></td>
			<td width="30%"><cellbytelabel id="4">Descripci&oacute;n de la Orden</cellbytelabel></td>
			<td width="40%"><cellbytelabel id="5">Mot. Rechazo</cellbytelabel></td> 
			<td width="5%"><cellbytelabel id="6">Confirmar</cellbytelabel></td>
		</tr>
<%
for (int i=0; i<al.size(); i++)
{
	cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
		<%=fb.hidden("secuenciaCorte"+i,cdo.getColValue("secuenciaCorte"))%>
		<%=fb.hidden("ejecutado"+i,cdo.getColValue("ejecutado"))%>
		<%=fb.hidden("tipo_orden"+i,cdo.getColValue("tipo_orden"))%>
		<%=fb.hidden("cod_salida"+i,cdo.getColValue("cod_salida"))%>

		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>
		<%=fb.hidden("orden_med"+i,cdo.getColValue("orden_med"))%>
		<%=fb.hidden("observacion"+i,"")%> 
		<%=fb.hidden("action"+i,cdo.getColValue("action"))%>
		<tr class="<%=color%>">
			<td align="center"><%=cdo.getColValue("fechaSolicitud")%></td>
			<td align="center"><%=cdo.getColValue("tipoOrden")%></td>
			<td>
				<%=cdo.getColValue("nombre")%>
				
			</td>
			<td align="left">
				 <%=cdo.getColValue("comentario_r")%><%if (cdo.getColValue("confirmado").equalsIgnoreCase("Y")){%>
				<label class="RedText">--> <cellbytelabel id="8">CONFIRMADO POR</cellbytelabel> - <%=cdo.getColValue("usuario_conf")%> -  <%=cdo.getColValue("fecha_conf")%></label>
				<%}%>
			</td>
			<td align="center"> 
				<%=fb.checkbox("confirmado"+i,"Y",(cdo.getColValue("confirmado").trim().equals("Y")?true:false),((UserDet.getRefType().trim().equalsIgnoreCase("M")|| UserDet.getXtra5().trim().equalsIgnoreCase("S"))?false:true||cdo.getColValue("confirmado").trim().equals("Y")),null,null,"")%>
			</td>

			 
		</tr>
<%
}
%>
		</table>
		</div>
		</div>
	</td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	for (int i=0; i<size; i++)
	{
		 
		/*  
		 
		dom.setUsuarioModificacion((String) session.getAttribute("_userName"));
		dom.setOmitirUsuario((String) session.getAttribute("_userName"));

		dom.setObserSuspencion(request.getParameter("observacion"+i));
		dom.setEstadoOrden(request.getParameter("suspender"+i));
		//dom.setFechaFin(request.getParameter("fechaFin"+i));
		dom.setCodSalida(request.getParameter("cod_salida"+i));
		dom.setFechaSuspencion(request.getParameter("fechaSuspencion"+i));
		dom.setComentarioCancela("SE CANCELA POR ANULACION DE ORDEN MEDICA");
*/
		//al.add(dom);
	   
	  if (request.getParameter("confirmado"+i) != null) 
	  {	
		cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_detalle_orden_med");
		cdo.setWhereClause("pac_id="+pacId+" and secuencia ="+request.getParameter("secuenciaCorte"+i)+" and tipo_orden="+request.getParameter("tipo_orden"+i)+" and orden_med="+request.getParameter("orden_med"+i)+" and codigo="+request.getParameter("codigo"+i));
		
 		cdo.setKey(i);
		cdo.setAction(request.getParameter("action"+i));  
		cdo.addColValue("fecha_modificacion","sysdate");	 
		cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("confirmado",request.getParameter("confirmado"+i)); 
		cdo.addColValue("usuario_conf",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_conf","sysdate");	 
		al.add(cdo);
	  }
 	}
	
	if (al.size() == 0)
	{
		cdo = new CommonDataObject();
		
		cdo.setTableName("tbl_sal_detalle_orden_med");
		cdo.setWhereClause("pac_id="+pacId+" and compania=-1");

		al.add(cdo);
	}

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	SQLMgr.saveList(al,true,false);
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	parent.reloadPage();
<%
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>