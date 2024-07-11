<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%--<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />--%>
<jsp:useBean id="htdesc" scope="session" class="java.util.Hashtable"/>
<%
/**
================================================================================
800055	AGREGAR TRANSACCIONES
800056	MODIFICAR E EMPLEADOS
================================================================================
**/
SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject desc= new CommonDataObject();
String sql="";
String key="";
String emp_id= request.getParameter("emp_id");
String prov=request.getParameter("prov");
String sig=request.getParameter("sig");
String tom=request.getParameter("tom");
String asi=request.getParameter("asi");
String num=request.getParameter("num");
String grp=request.getParameter("grp");
String rata=request.getParameter("rath");
String mode   = request.getParameter("mode");

ArrayList al= new ArrayList();
String change= request.getParameter("change");
//String fecha_inicial=
int desclastLineNo =0;

if(request.getParameter("desclastLineNo")!=null && ! request.getParameter("desclastLineNo").equals(""))
desclastLineNo=Integer.parseInt(request.getParameter("desclastLineNo"));
else desclastLineNo=0;

if (request.getMethod().equalsIgnoreCase("GET"))
{
desc.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));

sql="select e.num_empleado,to_char(e.provincia,'09') as primero, e.sigla as segundo, to_char(e.tomo,'09999') as tercero, to_char(e.asiento,'099999') as cuarto, e.primer_nombre as nameprimer, e.primer_apellido as Apellido, e.unidad_organi, to_char(e.salario_base,'999,999,990.00') as salario, to_char(e.rata_hora,'990.00') as rata, u.descripcion as unidad  from tbl_pla_empleado e, tbl_sec_unidad_ejec u where e.unidad_organi=u.codigo(+) and e.compania=u.compania(+) and e.compania="+(String) session.getAttribute("_companyId")+" and e.provincia="+prov+" and e.sigla='"+sig+"' and e.tomo="+tom+" and e.asiento="+asi+" and e.emp_id="+emp_id;
desc = SQLMgr.getData(sql);

if(change==null)
{
		htdesc.clear();

sql="select (a.provincia||'-'||a.sigla||'-'||a.tomo||'-'||a.asiento) as cedula, a.provincia, a.sigla, a.tomo, a.asiento, a.compania,  a.primer_nombre||' '||a.primer_apellido  as nombre ,a.primer_nombre, a.primer_apellido, a.ubic_seccion as seccion, b.descripcion as descSeccion, a.emp_id empid, d.emp_id as filtro, d.ue_codigo, to_char(d.fecha,'dd/mm/yyyy') as fecha, d.codigo, d.num_empleado, to_char(d.hora_entrada,'hh:mi') as hora_entrada, to_char(d.hora_salida,'hh:mi') as hora_salida, d.motivo, d.aprobado,  nvl(d.rrhh_recibido_estado,'N') as rrhh_recibido_estado, d.lugar, d.lugar_nombre, d.rrhh_aprobado, no_referencia , d.estado, d.forma_des, d.mfalta, d.tiempo_horas, d.tiempo_minutos , f.descripcion as descripcion  from tbl_pla_empleado a, tbl_sec_unidad_ejec b, tbl_pla_incapacidad d, tbl_pla_motivo_falta f  where a.compania = b.compania and a.ubic_seccion = b.codigo and a.emp_id = d.emp_id(+) and a.compania = d.compania(+) and d.mfalta = f.codigo and d.rrhh_recibido_estado = 'N' and a.compania="+(String) session.getAttribute("_companyId")+" and a.provincia="+prov+" and a.sigla='"+sig+"' and a.tomo="+tom+" and a.asiento="+asi+" and d.emp_id ="+emp_id+" order by d.fecha";

	al=SQLMgr.getDataList(sql);
desclastLineNo=al.size();
			for(int h=0;h<al.size();h++)
			{
			desclastLineNo++;

			if(desclastLineNo<10)

			key="00" + desclastLineNo;

			else if(desclastLineNo<100)

			key="0" + desclastLineNo;

			else
			key="" + desclastLineNo;

			htdesc.put(key,al.get(h));
			}
}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<script language="javascript">
document.title="Registro de Incapacidades de Empleados - Agregar - "+document.title;

function tipo(index)
{
abrir_ventana1("../common/search_motivo_falta.jsp?fp=incapacidad&index="+index);
}

function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
</script>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="REGISTRO DE INCAPACIDADES DE EMPLEADOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
		<td class="TableBorder">
			<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ==========================   F O R M   S T A R T   H E R E   ============================ -->
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.formStart(true)%>
	<%=fb.hidden("emp_id",emp_id)%>
	<%=fb.hidden("desclastLineNo",""+desclastLineNo)%>
	<%=fb.hidden("keySize",""+htdesc.size())%>
	<%=fb.hidden("prov",prov)%>
	<%=fb.hidden("sig",sig)%>
	<%=fb.hidden("tom",tom)%>
	<%=fb.hidden("asi",asi)%>
	<%=fb.hidden("baction","")%>
  	<%=fb.hidden("num",num)%>
	<%=fb.hidden("grp",grp)%>
	<%=fb.hidden("rata",rata)%>
	<%=fb.hidden("mode",mode)%>

	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>

	<tr class="TextRow02">
		<td colspan="4">&nbsp;</td>
	</tr>

	<tr class="TextHeader">
		<td colspan="4">&nbsp;Generales de Empleado</td>
	</tr>

	<tr class="TextRow01" >
		<td height="22">&nbsp;N&uacute;mero de C&eacute;dula</td>
		<td colspan="1">&nbsp;<%=desc.getColValue("primero")%>&nbsp;-&nbsp;<%=desc.getColValue("segundo")%>&nbsp;-&nbsp;<%=desc.getColValue("tercero")%>&nbsp;-&nbsp;<%=desc.getColValue("cuarto")%></td>
		<td width="20%">&nbsp;Rata por Hora</td>
		<td width="30%">&nbsp;<%=desc.getColValue("rata")%></td>
	</tr>

	<tr class="TextRow01">
		<td width="16%">&nbsp;Nombre</td>
		<td width="34%">&nbsp;<%=desc.getColValue("namePrimer")%></td>
		<td width="20%">&nbsp;Apellido</td>
		<td width="30%">&nbsp;<%=desc.getColValue("Apellido")%></td>
	</tr>

	<tr class="TextRow01">
		<td>&nbsp;Unidad Administrativa</td>
		<td>&nbsp;<%=desc.getColValue("unidad")%></td>
		<td>&nbsp;Salario Base</td>
		<td>&nbsp;<%=desc.getColValue("salario")%></td>
	</tr>

  	<tr class="TextRow01">
		<td>&nbsp;Grupo</td>
		<td>&nbsp;<%=desc.getColValue("unidad_organi")%></td>
		<td>&nbsp;Numero Empleado</td>
		<td>&nbsp;<%=desc.getColValue("num_empleado")%></td>
	</tr>

	<tr class="TextHeader">
		<td colspan="4">&nbsp;Registro de Incapacidades</td>
	</tr>
	<tr>
	<td colspan="4">
		<table width="100%">
    <tr class="TextHeader" align="center">
		<td width="10%" >N&uacute;m.</td>
    	<td width="20%" align="center">Fecha </td>
		<td width="15%" align="center">T. Desde </td>
		<td width="15%" align="center">T. Hasta </td>
		<td width="10%">Horas</td>
		<td width="15%">Minutos</td>
		<td width="10%">Recibida</td>
 		<td width="5%"><%=fb.submit("btnagregar","+",false,false)%></td>
	</tr>

  		<%
	String codigo="0";
	if(htdesc.size()>0)
	al=CmnMgr.reverseRecords(htdesc);
		//for(int i=0; i<htdesc.size();i++)
	for(int i=0; i<al.size();i++)
	{
	key=al.get(i).toString();
		CommonDataObject cdos=(CommonDataObject) htdesc.get(key);

		String color="";
	 	String fecha="fecha"+i;
		String hora_entrada="hora_entrada"+i;
		String hora_salida="hora_salida"+i;

		if(i%2 == 0) color ="TextRow02";

		else color="TextRow01";
	%>
	<%=fb.hidden("key"+i,key)%>
    <%=fb.hidden("ue_codigo"+i,cdos.getColValue("ue_codigo"))%>
	 <%=fb.hidden("num"+i,cdos.getColValue("num"))%>


	<tr class="<%=color%>">
			<td align="center">
			<%=fb.intBox("codigo"+i,cdos.getColValue("codigo"),true,false,false,5,3,"Text10",null,null)%>
			</td>
   			<td align="center">
			 	<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="<%=fecha%>" />
				<jsp:param name="valueOfTBox1" value="<%=(cdos.getColValue("fecha")==null)?"":cdos.getColValue("fecha")%>" />
				</jsp:include>
			</td>

 			 <td align="center">
			 	<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="<%=hora_entrada%>" />
				<jsp:param name="format" value="hh24:mi" />
				<jsp:param name="valueOfTBox1" value="<%=(cdos.getColValue("hora_entrada")==null)?"":cdos.getColValue("hora_entrada")%>" />
				</jsp:include>
			</td>

			 <td align="center">
			 	<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="<%=hora_salida%>" />
				<jsp:param name="format" value="hh24:mi" />
				<jsp:param name="valueOfTBox1" value="<%=(cdos.getColValue("hora_salida")==null)?"":cdos.getColValue("hora_salida")%>" />
				</jsp:include>
			</td>

			<td align="center">
				<%=fb.intBox("tiempo_horas"+i,cdos.getColValue("tiempo_horas"),true,false,false,4,2,"Text10",null,null)%>
			</td>
			<td align="center">
				<%=fb.intBox("tiempo_minutos"+i,cdos.getColValue("tiempo_minutos"),true,false,false,4,2,"Text10",null,null)%>
			</td>

  			<td align="center">
				<%=fb.checkbox("rrhh_recibido_estado"+i,"S",(cdos.getColValue("rrhh_recibido_estado") !=null && cdos.getColValue("rrhh_recibido_estado").trim().equalsIgnoreCase("S")),false)%>
			</td>

			<td align="center" rowspan="1">&nbsp;<%=fb.submit("remover"+i,"X",false,false)%></td>
	</tr>

   	<tr class="TextRow01" >
	   		<td colspan="8" align="center">
	<table >
  	<tr>
			<td>Tipo de Incapacidad
				<%=fb.intBox("mfalta"+i,cdos.getColValue("mfalta"),true,false,true,5,3,"Text10",null,null)%>
				<%=fb.textBox("descripcion"+i,cdos.getColValue("descripcion"),false,false,true,60,200,"Text10",null,null)%><%=fb.button("btnfalta"+i,"Ir",true,false,"Text10", null,"onClick=\"javascript:tipo("+i+")\"" )%></td>
	</tr>
	</table>
	</td>
 	</tr>

	<tr class="TextRow01" >
	    &nbsp;&nbsp;&nbsp;
    </tr>

	<tr class="TextRow01" >
	   	<td colspan="3">
   	<table>
	<tr>
	 	<td>Comentario</td>
		<td><%=fb.textarea("motivo"+i,cdos.getColValue("motivo"),false,false,false,50,4,"Text11",null,null)%></td>
	</tr>
	</table>
	</td>

    <td colspan="5">
	  	<table>
	 	<tr>
	   	  	<td width="37%">Acci&oacute;n</td>
	   		<td width="63%"><%=fb.select("estado"+i,"DS=DESCONTAR,ND=NO DESCONTAR",cdos.getColValue("estado"))%></td>
		</tr>

	<tr>
	 	<td>Tipo de Lugar</td>
		<td><%=fb.select("lugar"+i,"1=Clinica San Fernando,2=Caja de Seguro Social,3=Clinica Externa,4=Centro Médico,5=Otros",cdos.getColValue("lugar"),"S")%> &nbsp;&nbsp; No. Inc.:<%=fb.textBox("no_referencia"+i,cdos.getColValue("no_referencia"),false,false,false,8,12,"Text10",null,null)%></td>
	</tr>

    <tr>
	 	<td>Nombre del Lugar</td>
       	<td><%=fb.textarea("lugar_nombre"+i,cdos.getColValue("lugar_nombre"),false,false,false,20,2,"Text11",null,null)%></td>
	</tr>
	</table>
	</td>
	</tr>

	<%
	}
	%>
	</table>
 </td>
 </tr>


	<tr class="TextRow02">
        <td align="right" colspan="4"> Opciones de Guardar:
		<%=fb.radio("saveOption","N")%>Crear Otro
		<%=fb.radio("saveOption","O")%>Mantener Abierto
		<%=fb.radio("saveOption","C",true,false,false)%>Cerrar
		<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
		<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
    </tr>
			<%--<tr class="TextRow02">
				<td colspan="4" align="right"> <%//=fb.submit("save","Guardar",true,false)%>
				<%//=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%></td>
			</tr>	--%>
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
		 <%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
	</table>
	</td>
	</tr>
</table>

<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else if(request.getMethod().equalsIgnoreCase("POST"))
{
String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");

ArrayList list= new ArrayList();
desclastLineNo= Integer.parseInt(request.getParameter("desclastLineNo"));
int keySize=Integer.parseInt(request.getParameter("keySize"));
String itemRemoved="";

for(int a=0; a<keySize; a++)
{
 CommonDataObject cdo = new CommonDataObject();

// String fecha = request.getParameter("fecha_inicio"+a);

 String est = request.getParameter("rrhh_recibido_estado"+a);


  cdo.setTableName("tbl_pla_incapacidad");
  cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+prov+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi+" and emp_id="+emp_id);
  cdo.addColValue("emp_id",emp_id);
  cdo.addColValue("provincia",prov);
  cdo.addColValue("sigla",sig);
  cdo.addColValue("tomo",tom);
  cdo.addColValue("asiento",asi);
  cdo.addColValue("ue_codigo",grp);
  cdo.addColValue("num_empleado",num);
  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));


  cdo.addColValue("fecha",request.getParameter("fecha"+a));
  cdo.addColValue("hora_entrada",request.getParameter("hora_entrada"+a));
  cdo.addColValue("hora_salida",request.getParameter("hora_salida"+a));
  cdo.addColValue("estado",request.getParameter("estado"+a));
  cdo.addColValue("motivo",request.getParameter("motivo"+a));
  cdo.addColValue("forma_des","1");
  cdo.addColValue("aprobado","N");
  cdo.addColValue("rrhh_aprobado","N");
  cdo.addColValue("lugar",request.getParameter("lugar"+a));
  cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
  cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
  cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
  cdo.addColValue("tiempo_horas",request.getParameter("tiempo_horas"+a));
  cdo.addColValue("tiempo_minutos",request.getParameter("tiempo_minutos"+a));


  cdo.addColValue("lugar_nombre",request.getParameter("lugar_nombre"+a));
   cdo.addColValue("no_referencia",request.getParameter("no_referencia"+a));

    cdo.addColValue("mfalta",request.getParameter("mfalta"+a));


	if(request.getParameter("rrhh_recibido_estado"+a)==null  || request.getParameter("rrhh_recibido_estado"+a)=="N")
	{
	 cdo.addColValue("rrhh_recibido_estado","N");
	}
	else
	{
	cdo.addColValue("rrhh_recibido_fecha",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
	 cdo.addColValue("rrhh_recibido_usuario",(String) session.getAttribute("_userName"));
	cdo.addColValue("rrhh_recibido_estado",request.getParameter("rrhh_recibido_estado"+a));
	}


 	cdo.addColValue("codigo",request.getParameter("codigo"+a));
//	cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+request.getParameter("prov")+" and sigla='"+request.getParameter("sig")+"' and tomo="+request.getParameter("tom")+" and asiento="+request.getParameter("asi")+" and emp_id="+request.getParameter("emp_id"));
 	cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+request.getParameter("prov")+" and sigla='"+request.getParameter("sig")+"' and tomo="+request.getParameter("tom")+" and asiento="+request.getParameter("asi")+" and emp_id="+request.getParameter("emp_id") );
    cdo.setAutoIncCol("codigo");
  	key=request.getParameter("key"+a);

    if(request.getParameter("remover"+a)==null)
  {
	  try
	  {
	  htdesc.put(key,cdo);
	  list.add(cdo);
	  }
	  catch(Exception e)
	  {
	   System.err.println(e.getMessage());
	  }
  }
  else itemRemoved= key;
 }//End For

if(!itemRemoved.equals(""))
{
htdesc.remove(key);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&emp_id="+emp_id+"&grp="+grp+"&num="+num+"&desclastLineNo="+desclastLineNo);
//response.sendRedirect("../rhplanilla/descuento_config.jsp?change=1&desclastLineNo="+desclastLineNo+"&emp_id="+emp_id);
return;
}
if(request.getParameter("btnagregar")!=null)
{
CommonDataObject cdo = new CommonDataObject();
cdo.addColValue("mfalta","");
cdo.addColValue("codigo","0");
cdo.addColValue("fecha_inico","");
cdo.addColValue("hora_entrada","");
cdo.addColValue("hora_salida","");

cdo.addColValue("fecha_inicio",CmnMgr.getCurrentDate("dd/mm/yyyy"));
desclastLineNo++;

if(desclastLineNo<10)
key="00" + desclastLineNo;
else if(desclastLineNo<100)
key="0"+desclastLineNo;
else key=""+desclastLineNo;
htdesc.put(key,cdo);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&emp_id="+emp_id+"&grp="+grp+"&num="+num+"&desclastLineNo="+desclastLineNo);
 return;
}

SQLMgr.insertList(list);

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
<%
	//if (tab.equals("0"))
	//{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/incapacidades_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/incapacidades_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/incapacidades_list.jsp';
<%
		}
	//}

	if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
	{
%>
	setTimeout('editMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("C"))
	{
%>
	window.close();
<%
	}
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&emp_id=<%=emp_id%>&grp=<%=grp%>&num=<%=num%>';
}

</script>

</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
