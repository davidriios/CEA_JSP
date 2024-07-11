<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="java.util.Vector"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<%
/**
==================================================================================
sct0100s----------------
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

String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy");
String cDateAnio = CmnMgr.getCurrentDate("yyyy");

String userName = UserDet.getUserName();

StringBuffer sbSql = new StringBuffer();

String compania = (String)session.getAttribute("_companyId");
String grupo = (request.getParameter("grupo")==null?"":request.getParameter("grupo"));
String empId = (request.getParameter("empId")==null?"":request.getParameter("empId"));
String nombre = (request.getParameter("nombre")==null?"":request.getParameter("nombre"));
String cedula = (request.getParameter("cedula")==null?"":request.getParameter("cedula"));
String dias = "";
String fg = (request.getParameter("fg")==null?"":request.getParameter("fg"));
String appendFilter = "";
if (!fg.equals(""))appendFilter += " and a.aprobado = 'S' and a.anio_pago = to_char(c.fecha_inicial,'YYYY') and a.periodo_pago = (to_char(c.fecha_inicial,'MM') * 2 - decode(mod(c.periodo,2),0,0,1))";

if(!grupo.equals("1")) dias += "2";
else dias += "5";


sbSql.append("select a.compania, a.ue_codigo, a.anio, a.periodo, a.provincia, a.sigla, a.tomo, a.asiento, a.codigo, to_char(a.te_hent,'dd-mm-yyyy hh:mi am') teHent, to_char(a.fecha,'dd-mm-yyyy') fecha_dsp, to_char(a.te_hent,'dd/mm/yyyy hh:mi am') te_hent, to_char(a.te_hsal,'dd/mm/yyyy hh:mi am') te_hsal, a.observaciones, a.aprobado, a.actualizado,  getta_tp(a.provincia,a.sigla,a.tomo, a.asiento, a.compania,a.ue_codigo,a.anio,a.periodo,a.fecha) ta_tp, (to_char(c.fecha_inicial,'MM') * 2 - decode(mod(c.periodo,2),0,0,1))  periodo_pago, to_char(c.fecha_inicial,'YYYY') anio_pago from tbl_pla_st_det_turext a, /*tbl_pla_calendario */  (select c.periodo, c.trans_hasta, c.tipopla, c.fecha_inicial  from tbl_pla_calendario c where c.tipopla=1 and c.fecha_inicial <= trunc(sysdate)     and c.fecha_cierre+1 >= trunc(sysdate)) c where a.ue_codigo = ");
sbSql.append(grupo);
//sbSql.append(" and to_date(to_char(fecha,'DD-MM-YYYY'),'DD-MM-YYYY') <= (select trans_hasta+1 from tbl_pla_calendario where tipopla    = 1 and fecha_cierre+"+dias+" >= to_date(to_char(sysdate,'DD-MM-YYYY'),'DD-MM-YYYY') and fecha_inicial = (select min(x.fecha_inicial) from tbl_pla_calendario x where x.tipopla = 1 and   x.fecha_cierre+"+dias+"  >= to_date(to_char(sysdate,'DD-MM-YYYY'),'DD-MM-YYYY') )  and rownum = 1) and (a.actualizado = 'N' or a.actualizado is null) and  to_date(to_char(sysdate,'DD-MM-YYYY'),'DD-MM-YYYY' ) >= to_date(to_char(c.trans_desde,'DD-MM-YYYY'),'DD-MM-YYYY') and to_date(to_char(sysdate,'DD-MM-YYYY'),'DD-MM-YYYY' ) <= to_date(to_char(c.trans_hasta+1,'DD-MM-YYYY'),'DD-MM-YYYY') and c.tipopla= 1  and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and a.emp_id = ");
sbSql.append(" and (a.actualizado = 'N' or a.actualizado is null) and  c.tipopla= 1  and a.compania = "+(String) session.getAttribute("_companyId")+appendFilter+" and a.emp_id = ");
sbSql.append(empId);
sbSql.append(" order by a.fecha desc ");

al = SQLMgr.getDataList(sbSql.toString());

if (request.getMethod().equalsIgnoreCase("GET")) {
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
function doAction(){}
function setAprobValue(ind){
   var aprobadoValObj = document.getElementById("aprobadoVal"+ind);
   var aprobado = document.getElementById("aprobado"+ind);
   if (aprobado.checked == true){
      aprobadoValObj.value = "S";
   }else{aprobadoValObj.value = "N";}
}
function setAprobValueA(ind){
   var actualizadoValObj = document.getElementById("actualizadoVal"+ind);
   var actualizado = document.getElementById("actualizado"+ind);
   if (actualizado.checked == true){
      actualizadoValObj.value = "S";
   }else{actualizadoValObj.value = "N";}
}


function doCall()
{
	verCheck();
}

function verCheck()
{
var size = parseInt(eval('document.form01.size').value);
var totalCheck = 0;
var est = "'D'";
var an=0;
var num=0;
var cod=0;

if(size>0)
	{
for (i=0;i< size;i++)
	{
	if (eval('document.form01.actualizado'+i).checked)
	{
	setAprobValueA(i);
	}
	}
	}
}

</script>
<style type="text/css">
</style>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">

<table align="center" width="100%" cellpadding="0" cellspacing="1">
<%fb = new FormBean("form01",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("grupo",""+grupo)%>
<%=fb.hidden("empId",""+empId)%>
<%=fb.hidden("nombre",""+nombre)%>
<%=fb.hidden("cedula",""+cedula)%>
<%=fb.hidden("fg",""+fg)%>
<%=fb.hidden("size",""+al.size())%>

<tr class="TextPanel">

<% if(!fg.equals("")) { %>
<td>Aprobacion de Sobretiempos</td>
<% } else { %>
	<td>Detalle de Sobretiempos</td>
	<% } %>
</tr>
<tr class="TextPanel">


<td>Correspondientes a :&nbsp;&nbsp;<%=nombre%> &nbsp; <%=cedula%></td>

</tr>

<tr>
 <td width="100%" align="right" class="TextRow02">

  <%=fb.submit("saveUP",fg.equals("ap")?"Aprobar":"Guardar",true,false,"","","onClick=\"javascript:setBAction('form01', this.value);\"")%>

 </td>
</tr>
<tr class="TextRow01">
  <td>
     <table width="100%" cellpadding="1" cellspacing="1">
	     <tr class="TextHeader02">
		    <td width="10%" align="center">Fecha</td>
			<td width="10%" align="center">Turno Asignado</td>
			<td width="18%" align="center">D&iacute;a / Hora Inicio</td>
			<td width="18%" align="center">D&iacute;a / Hora Final</td>
			<td width="10%" align="center">Turno Posterior</td>
			<td width="29%" >Observaciones</td>
			<td width="5%" align="center">
			<% if(!fg.equals("")) {
				 %>
			&nbsp;Sel.<br> <%=fb.checkbox("chk","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','actualizado',"+al.size()+",this);doCall()\"","Seleccionar todos los Registros listados. !")%>

			</td>
		 	 <% } else { %>
		 	&nbsp;
		 	<%}%>
		 </tr>
		 <%
		   String[] taTp;
		   String turnoAsignado = "", turnoPosterior = "";
		 //  if (al.size() > 0) al = CmnMgr.reverseRecords(al);
		 System.out.println("************* al.size()"+al.size());
		   for (int d = 0; d<al.size(); d++){
		      cdo = (CommonDataObject)al.get(d);
			  String color = "TextRow02";
			  if (d % 2 == 0) color = "TextRow01";
			  boolean aprobado = false;
			  boolean actualizado = false;
			  if (cdo.getColValue("aprobado") != null && cdo.getColValue("aprobado").equals("S")){
			       aprobado = true;
			  }
			  if (cdo.getColValue("actualizado") != null && cdo.getColValue("actualizado").equals("S")){
			       actualizado = true;
			  }

			  try{
			     taTp = cdo.getColValue("ta_tp").split("<>");
				 turnoAsignado = taTp[0].trim();
				 turnoPosterior = taTp[1].trim();
				 if (turnoAsignado.length() <= 1) {turnoAsignado  = "NDF";}
				 if (turnoPosterior.length() <= 1){turnoPosterior = "NDF";}
			  }catch(Exception e){
			     System.out.println(">>>>>>>>>>>>>>>> THEBRAIN SAYS THE STRING CANNOT BE SPLITTED BECAUSE OF: "+e);
			  }
	     %>
			   <%=fb.hidden("compania"+d,cdo.getColValue("compania"))%>
			   <%=fb.hidden("ue_codigo"+d,cdo.getColValue("ue_codigo"))%>
			   <%=fb.hidden("codigo"+d,cdo.getColValue("codigo"))%>
			   <%=fb.hidden("anio"+d,cdo.getColValue("anio"))%>
			   <%=fb.hidden("periodo"+d,cdo.getColValue("periodo"))%>
			   <%=fb.hidden("periodo_pago"+d,cdo.getColValue("periodo_pago"))%>
			   <%=fb.hidden("provincia"+d,cdo.getColValue("provincia"))%>
			   <%=fb.hidden("sigla"+d,cdo.getColValue("sigla"))%>
			   <%=fb.hidden("tomo"+d,cdo.getColValue("tomo"))%>
			   <%=fb.hidden("asiento"+d,cdo.getColValue("asiento"))%>
			   <%=fb.hidden("fecha"+d,cdo.getColValue("fecha_dsp"))%>
			   <%=fb.hidden("observacionesDB"+d,cdo.getColValue("observaciones"))%>
			   <%=fb.hidden("actualizadoVal"+d,cdo.getColValue("actualizado"))%>
			   <%=fb.hidden("actualizadoDB"+d,cdo.getColValue("actualizado"))%>
			   <%=fb.hidden("aprobadoDB"+d,cdo.getColValue("aprobado"))%>
			   <%=fb.hidden("aprobadoVal"+d,cdo.getColValue("aprobado"))%>
			   <%=fb.hidden("action"+d,"U")%>
			    <%=fb.hidden("teHent"+d,cdo.getColValue("teHent"))%>


			   <% if(!fg.equals("")) { %>
			   <%=fb.hidden("aprobadoDB"+d,"N")%>
			   <% } %>

			   <tr id="det<%=d%>" name="det<%=d%>" class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			      <td align="center"><%=cdo.getColValue("fecha_dsp")%></td>
				  <td align="center"><%=turnoAsignado%></td>
				  <td align="center">
				  	<% if(!fg.equals("")) { %>

				    		<%=fb.textBox("te_hent"+d,cdo.getColValue("te_hent"),false,false,false,19,19)%>

				     	<% } else { %>
				     		<%=cdo.getColValue("te_hent")%>
				     	<% } %>
				  </td>
				  <td align="center">
				  	<% if(!fg.equals("")) { %>
				      		<%=fb.textBox("te_hsal"+d,cdo.getColValue("te_hsal"),false,false,false,19,19)%>
				      	<% } else { %>
				       		<%=cdo.getColValue("te_hsal")%>
				     	<% } %>
				  </td>
				  <td align="center"><%=turnoPosterior%></td>
				  <td>
				     <%=fb.textarea("observaciones"+d,cdo.getColValue("observaciones"),false,false,false,35,1,200,null,null,"")%>
				  </td>
				 <% if(!fg.equals("")) {
				 %>
				 <td align="center"><%=fb.checkbox("actualizado"+d,cdo.getColValue("actualizado"),actualizado,false,null,null,"onclick=\"setAprobValueA("+d+")\"")%></td>
				 <% } else { %>
				  <td align="center"><%=fb.checkbox("aprobado"+d,cdo.getColValue("aprobado"),aprobado,false,null,null,"onclick=\"setAprobValue("+d+")\"")%></td>
			   	<% } %>
			   </tr>

		 <%  }//for d %>
	 </table>
  </td>
</tr>
<tr>
 <td width="100%" align="right" class="TextRow02">
  <%=fb.submit("saveUP",fg.equals("ap")?"Aprobar":"Guardar",true,false,"","","onClick=\"javascript:setBAction('form01', this.value);\"")%>
  </td>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else{
  String baction = request.getParameter("baction");
  fg = request.getParameter("fg");
  int size = Integer.parseInt(request.getParameter("size"));
  int cnt = 0;
  al.clear();


  for (int i=0; i<size; i++) {

		if ((request.getParameter("observaciones"+i)!=null && !request.getParameter("observaciones"+i).equals("")) || (request.getParameter("aprobadoVal"+i)!=null && !request.getParameter("aprobadoVal"+i).equals("")))
		{

			if ((!request.getParameter("observaciones"+i).trim().equalsIgnoreCase(request.getParameter("observacionesDB"+i).trim())) || (!request.getParameter("aprobadoVal"+i).equals(request.getParameter("aprobadoDB"+i))) || (!request.getParameter("actualizadoVal"+i).equals(request.getParameter("actualizadoDB"+i))))
			{

				cdo = new CommonDataObject();
				cdo.setTableName("tbl_pla_st_det_turext");
				cdo.setAction(request.getParameter("action"+i));

				cdo.addColValue("observaciones",request.getParameter("observaciones"+i));
				cdo.addColValue("aprobado",request.getParameter("aprobadoVal"+i));
				cdo.addColValue("aprobado_por",(String) session.getAttribute("_userName"));

				if (request.getParameter("aprobadoVal"+i).equals("S"))
				{
				cdo.addColValue("anio_pago",cDateAnio);
				cdo.addColValue("periodo_pago",request.getParameter("periodo_pago"+i));
				} else
				{
				cdo.addColValue("anio_pago","");
				cdo.addColValue("periodo_pago","");
				}


				if (fg.equalsIgnoreCase("ap"))
				{
				cdo.addColValue("actualizado",request.getParameter("aprobadoVal"+i));
				cdo.addColValue("actualizado_por",(String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_actualizado",cDateTime);


				cdo.addColValue("te_hent",request.getParameter("te_hent"+i));
				cdo.addColValue("te_hsal",request.getParameter("te_hsal"+i));


				}

				StringBuffer sbWhere = new StringBuffer();

				sbWhere.append("emp_id = ");
				sbWhere.append(empId);
				sbWhere.append(" and compania = ");
				sbWhere.append(request.getParameter("compania"+i));
				sbWhere.append(" and ue_codigo = ");
				sbWhere.append(request.getParameter("ue_codigo"+i));
				sbWhere.append(" and anio = ");
				sbWhere.append(request.getParameter("anio"+i));
				sbWhere.append(" and periodo = ");
				sbWhere.append(request.getParameter("periodo"+i));
				sbWhere.append(" and provincia = ");
				sbWhere.append(request.getParameter("provincia"+i));
				sbWhere.append(" and sigla = '");
				sbWhere.append(request.getParameter("sigla"+i));
				sbWhere.append("' and tomo = ");
				sbWhere.append(request.getParameter("tomo"+i));
				sbWhere.append(" and asiento = ");
				sbWhere.append(request.getParameter("asiento"+i));
				sbWhere.append(" and fecha = ");
				sbWhere.append("to_date('"+request.getParameter("fecha"+i)+"','dd/mm/yyyy')");
				sbWhere.append(" and codigo = ");
				sbWhere.append(request.getParameter("codigo"+i));

				cdo.setWhereClause(sbWhere.toString());
		        al.add(cdo);
			}
	  }

    }//for i

    if (baction.equalsIgnoreCase("Guardar")||baction.equalsIgnoreCase("Aprobar")) {
	   if (al.size() > 0){
	        System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> THEBRAIN: UPDATING AL SIZE  = "+al.size());
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			SQLMgr.saveList(al,false);
			//SQLMgr.updateList(al);
			ConMgr.clearAppCtx(null);
		}else{
		   System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>THEBRAIN: NOTHING TO UPDATE");
		   SQLMgr.setErrCode("1");
		   SQLMgr.setErrMsg("Como que no ha cambiado nada, tampoco actualizaremos la base de datos!");
		}
	}
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1")){
%>
	<% if(!fg.equals("")) {
	%>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=ap&empId=<%=empId%>&grupo=<%=grupo%>';
	<% } else { %>


	alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?empId=<%=empId%>&grupo=<%=grupo%>';
<%
} } else throw new Exception(SQLMgr.getErrMsg());
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