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
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="iMotivo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iIncen" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iSueldo" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iAumento" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iBono" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vMotivo" scope="session" class="java.util.Vector" />
<jsp:useBean id="vCargo" scope="session" class="java.util.Vector" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" /> 
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),""))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al= new ArrayList();	
String sql="";
String mode=request.getParameter("mode");
String id=request.getParameter("id");
String tab = request.getParameter("tab");
String change = request.getParameter("change");
String cDateTime =  CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String key = "";
int motiLastLineNo =0; 
int incenLastLineNo =0; 
int sueldoLastLineNo =0; 
int aumenLastLineNo =0; 
int bonoLastLineNo =0; 

if (tab == null) tab = "0";
if (mode == null || mode == "") mode = "add";
if (request.getParameter("motiLastLineNo") != null) motiLastLineNo = Integer.parseInt(request.getParameter("motiLastLineNo"));
if (request.getParameter("incenLastLineNo") != null) incenLastLineNo = Integer.parseInt(request.getParameter("incenLastLineNo"));
if (request.getParameter("sueldoLastLineNo") != null) sueldoLastLineNo = Integer.parseInt(request.getParameter("sueldoLastLineNo"));
if (request.getParameter("aumenLastLineNo") != null) aumenLastLineNo = Integer.parseInt(request.getParameter("aumenLastLineNo"));
if (request.getParameter("bonoLastLineNo") != null) bonoLastLineNo = Integer.parseInt(request.getParameter("bonoLastLineNo"));

fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);
if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";	
			cdo.addColValue("vigente_desde","");
			cdo.addColValue("vigente_hasta","");
			iMotivo.clear();
			iIncen.clear();
			iSueldo.clear();
			iAumento.clear();
			iBono.clear();
			vMotivo.clear();
			vCargo.clear();
	}
	else
	{
		//if (id == null) throw new Exception("Los Parámetros de Convención Colectiva no es válido. Por favor intente nuevamente!");

sql = "select estado, to_char(vigente_desde,'dd/mm/yyyy')as vigente_desde, to_char(vigente_hasta,'dd/mm/yyyy')as vigente_hasta, subsidio_muerte as subsidio, descto_x_duelo as duelo,valor_x_alto_riesgo as valor, cantidad_max_cambio_turno as cambio from tbl_pla_parametros_cc where cod_compania = "+session.getAttribute("_companyId");
		cdo = SQLMgr.getData(sql);
		if(change == null)
		{
		
			iMotivo.clear();
			iIncen.clear();
			iSueldo.clear();
			iAumento.clear();
			iBono.clear();
			vMotivo.clear();
			vCargo.clear();
		
		//Subsidio x incapacidad 
		sql="select a.motivo_falta, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss') as fecha_creacion,a.usuario_creacion ,b.descripcion from tbl_pla_cc_param_sub_x_incap a,tbl_pla_motivo_falta b where a.motivo_falta=b.codigo(+) and compania ="+session.getAttribute("_companyId");//id
		
		al  = SQLMgr.getDataList(sql);
		motiLastLineNo = al.size();
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cd = (CommonDataObject) al.get(i);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			cd.addColValue("key",key);
			try
			{
				iMotivo.put(key, cd);
				vMotivo.add(cd.getColValue("motivo_falta"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		//incapacidad x asistencia
		sql="select rango_inicial, rango_final,dias_pagar, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss') as fecha_creacion, usuario_creacion from tbl_pla_cc_param_inc_x_asist where compania ="+session.getAttribute("_companyId");
		al  = SQLMgr.getDataList(sql);
		incenLastLineNo = al.size();
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cd = (CommonDataObject) al.get(i);
			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			cd.addColValue("key",key);
			try
			{
				iIncen.put(key, cd);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		if (al.size() == 0)
		{
			CommonDataObject cd= new CommonDataObject();
			cd.addColValue("rango_inicial","");
			cd.addColValue("fecha_creacion",cDateTime);   
			cd.addColValue("usuario_creacion",(String) session.getAttribute("_userName")); 
			incenLastLineNo++;
			if (incenLastLineNo < 10) key = "00" + incenLastLineNo;
			else if (incenLastLineNo < 100) key = "0" + incenLastLineNo;
			else key = "" + incenLastLineNo;
			cd.addColValue("key",key);

			try
			{
				iIncen.put(key, cd);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		//sobresueldos
		sql="select a.cargo, a.periodicidad,a.valor, to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss')as fecha_creacion, a.usuario_creacion as, to_char(a.fecha_inicio,'dd/mm/yyyy hh12:mi:ss')as fecha_inicio, b.denominacion from tbl_pla_cc_param_sobresueldos a,tbl_pla_cargo b where a.cargo=b.codigo(+) and a.compania="+session.getAttribute("_companyId");
		al  = SQLMgr.getDataList(sql);
		sueldoLastLineNo = al.size();
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cd = (CommonDataObject) al.get(i);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			cd.addColValue("key",key);

			try
			{
				iSueldo.put(key, cd);
			  vCargo.add(cd.getColValue("cargo"));
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		//aumento general 
		sql="select anio, rango_inicial, rango_final,monto, to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss')as fecha_creacion, usuario_creacion from tbl_pla_cc_rango_aumentos  where compania="+session.getAttribute("_companyId");
		al  = SQLMgr.getDataList(sql);
		aumenLastLineNo = al.size();
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cd = (CommonDataObject) al.get(i);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			cd.addColValue("key",key);

			try
			{
				iAumento.put(key, cd);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		if (al.size() == 0)
		{
			CommonDataObject cd = new CommonDataObject();
			cd.addColValue("rango_inicial","");
			cd.addColValue("fecha_creacion",cDateTime);   
			cd.addColValue("usuario_creacion",(String) session.getAttribute("_userName")); 
			aumenLastLineNo++;
			if (aumenLastLineNo < 10) key = "00" + aumenLastLineNo;
			else if (aumenLastLineNo < 100) key = "0" + aumenLastLineNo;
			else key = "" + aumenLastLineNo;
			cd.addColValue("key",key);
			try
			{
				iAumento.put(key, cd);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		//bonificacion x jubilacion
		sql="select rango_inicial, rango_final, bonificacion  from tbl_pla_rango_bonif_jub where compania = "+session.getAttribute("_companyId");
al  = SQLMgr.getDataList(sql);
		bonoLastLineNo = al.size();
		for (int i=0; i<al.size(); i++)
		{
			CommonDataObject cd = (CommonDataObject) al.get(i);

			if (i < 10) key = "00" + i;
			else if (i < 100) key = "0" + i;
			else key = "" + i;
			cd.addColValue("key",key);
			try
			{
				iBono.put(key, cd);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

		if (al.size() == 0)
		{
			CommonDataObject cd = new CommonDataObject();
			cdo.addColValue("rango_inicial","");
			bonoLastLineNo++;
			if (bonoLastLineNo < 10) key = "00" + bonoLastLineNo;
			else if (bonoLastLineNo < 100) key = "0" + bonoLastLineNo;
			else key = "" + bonoLastLineNo;
			cd.addColValue("key",key);
			try
			{
				iBono.put(key, cd);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	 }
	}

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/tab.jsp" %>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
<%if (mode.equalsIgnoreCase("add")){%>
document.title="Parámetros Generales - Agregar - "+document.title;
<%}else if (mode.equalsIgnoreCase("edit")){%>
document.title="Parámetros Generales - Editar - "+document.title;
<%}%>
function chkNullValues(t)
{
  var x = 0;
	
	if ( t=="0")
		{
			if(document.form0.vigente.value=="")
			{
			alert('Seleccione valor vigencia !');
			x++;
			}
				if(document.form0.vigente_hasta.value=="")
				{
				alert('Seleccione valor en vigencia hasta!');
				x++;
				}
			if(x>0)	return false;
			else return true;
		}
	 
	 if(t=="2")
		{ 
		  for (i=0;i<parseInt(document.form2.iSize.value);i++)
		  {	
			for (j=(i+1);j<parseInt(document.form2.iSize.value);j++)
			{	
				if(eval('document.form2.rango_inicial'+i).value == eval('document.form2.rango_inicial'+j).value)
				{
					x++;
					eval('document.form2.rango_inicial'+j).value="";
				}
			}
		  }	
		  if(x>0) alert('Los valores en rango inicial no pueden estar repetidos');//return false;*/
		}
	 
	 if (t=="4")
	 {
		for (i=0;i<parseInt(document.form4.aSize.value);i++)
		{	
			for (j=(i+1);j<parseInt(document.form4.aSize.value);j++)
			{	
			if((eval('document.form4.rango_inicial'+i).value == eval('document.form4.rango_inicial'+j).value) && (eval('document.form4.anio'+i).value == eval('document.form4.anio'+j).value))
				{
					x++; 
					eval('document.form4.rango_inicial'+i).value="";
				}
			}
	 	}	
		if(x>0) alert('Los valores en rango inicial no pueden estar repetidos');
	 }

}
function doAction()
{
<%
	if (request.getParameter("type") != null)
	{
		if (tab.equals("1"))
		{
%>
	showMotivoList();
<%
		}
		else if (tab.equals("3"))
		{
%>
	showCargoList();
<%
		}
	}
%>
}
function showCargoList()
{
 abrir_ventana1('../common/check_cargo.jsp?fp=convencion&id=1&tab=1&mode=<%=mode%>&motiLastLineNo=<%=motiLastLineNo%>&incenLastLineNo=<%=incenLastLineNo%>&sueldoLastLineNo=<%=sueldoLastLineNo%>&aumenLastLineNo=<%=aumenLastLineNo%>&bonoLastLineNo=<%=bonoLastLineNo%>');
}
function showMotivoList()
{
 abrir_ventana1('../common/check_motivo.jsp?fp=convencion&&tab=3&id=1&mode=<%=mode%>&motiLastLineNo=<%=motiLastLineNo%>&incenLastLineNo=<%=incenLastLineNo%>&sueldoLastLineNo=<%=sueldoLastLineNo%>&aumenLastLineNo=<%=aumenLastLineNo%>&bonoLastLineNo=<%=bonoLastLineNo%>');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PARÁMETROS GENERALES"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="1" cellspacing="1">   
	<tr>  
		<td>   
<!-- MAIN DIV START HERE -->
<div id = "dhtmlgoodies_tabView1">
<!-- TAB0 DIV START HERE-->
<div class = "dhtmlgoodies_aTab">
				<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
				<table width="100%" cellpadding="1" cellspacing="1" > 
				 <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				 <%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
				 <%=fb.formStart(true)%> 
				 <%=fb.hidden("mode",mode)%>
				 <%=fb.hidden("tab","0")%>
				 <%=fb.hidden("baction","")%>
				 <%=fb.hidden("id",id)%>
				 <%=fb.hidden("mSize",""+iMotivo.size())%>
				 <%=fb.hidden("iSize",""+iIncen.size())%>
				 <%=fb.hidden("sSize",""+iSueldo.size())%>
				 <%=fb.hidden("aSize",""+iAumento.size())%>
				 <%=fb.hidden("bSize",""+iBono.size())%>
				 <%=fb.hidden("motiLastLineNo",""+motiLastLineNo)%>
				 <%=fb.hidden("incenLastLineNo",""+incenLastLineNo)%>
				 <%=fb.hidden("sueldoLastLineNo",""+sueldoLastLineNo)%>
				 <%=fb.hidden("aumenLastLineNo",""+aumenLastLineNo)%>
				 <%=fb.hidden("bonoLastLineNo",""+bonoLastLineNo)%>
				 	
			<tr class="TextRow02">
				<td colspan="2">&nbsp;</td>
			</tr>	
			<tr class="TextHeader">
				<td colspan="2">&nbsp;Estado de la Parámetro</td>
			</tr>
			<tr class="TextRow01">
				<td width="15%">Estado</td>
				<td width="85%"><%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"))%></td>
			</tr>
			<tr class="TextRow01">
				<td>Vigencia</td>
				<td>Del
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="vigente" />
					<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("vigente_desde")==null)?"":cdo.getColValue("vigente_desde")%>" />
					</jsp:include> &nbsp;Al&nbsp;
					<jsp:include page="../common/calendar.jsp" flush="true">
					<jsp:param name="noOfDateTBox" value="1" />
					<jsp:param name="nameOfTBox1" value="vigente_hasta" />
					<jsp:param name="valueOfTBox1" value="<%=(cdo.getColValue("vigente_desde")==null)?"":cdo.getColValue("vigente_hasta")%>" />
					</jsp:include>
				</td>
			</tr>
	<tr class="TextRow01">
	<td colspan="2">
	<table width="100%">	
	<tr class="TextRow01">
		<td width="25%">&nbsp;Subsidio x Fallecimiento</td>
		<td width="25%"><%=fb.decBox("subsidio",cdo.getColValue("subsidio"),true,false,false,10,3.2)%></td>
		<td width="25%">&nbsp;Ayuda Mortuoria</td>
		<td width="25%"><%=fb.decBox("duelo",cdo.getColValue("duelo"),true,false,false,10,5.2)%></td>
	</tr>
	
	<tr class="TextRow01">
		<td>&nbsp;Valor a Pagar x Alto Riesgo</td>
		<td><%=fb.decBox("valor",cdo.getColValue("valor"),true,false,false,10,3.2)%></td>
		<td>&nbsp;Cantidad M&aacute;xima de Cambios de Turnos por Mes</td>
		<td><%=fb.intBox("cambio",cdo.getColValue("cambio"),false,false,false,10,2)%></td>
	</tr>						
	</table>
	</td>
	</tr>			
				
	<tr class="TextRow02">
		<td colspan="4" align="right">
			Opciones de Guardar: 
			<!----><%=fb.radio("saveOption","N",false,false,false)%>Crear Otro 
			<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
			<%=fb.radio("saveOption","C",false,false,false)%>Cerrar 
			<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
			<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
		</td>
	</tr>
			 <%
		     fb.appendJsValidation("\n\tif (!chkNullValues(0)) error++;\n");
			 %>
			 <%=fb.formEnd(true)%>
	</table>	
	<!-- TAB0 DIV END HERE-->
</div>
<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

	<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mSize",""+iMotivo.size())%>
<%=fb.hidden("iSize",""+iIncen.size())%>
<%=fb.hidden("sSize",""+iSueldo.size())%>
<%=fb.hidden("aSize",""+iAumento.size())%>
<%=fb.hidden("bSize",""+iBono.size())%>
<%=fb.hidden("motiLastLineNo",""+motiLastLineNo)%>
<%=fb.hidden("incenLastLineNo",""+incenLastLineNo)%>
<%=fb.hidden("sueldoLastLineNo",""+sueldoLastLineNo)%>
<%=fb.hidden("aumenLastLineNo",""+aumenLastLineNo)%>
<%=fb.hidden("bonoLastLineNo",""+bonoLastLineNo)%>


<tr class="TextHeader">
				<td colspan="3">Motivos de Faltas </td>
</tr>
<tr class="TextHeader" align="center">
	<td width="35%">Compañia</td>
	<td width="60%">Motivo de Falta</td>
	<td width="5%"><%=fb.submit("agregar","+",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Motivo de Falta")%></td>
</tr>
<%
al = CmnMgr.reverseRecords(iMotivo);	
for (int i=0; i<iMotivo.size(); i++)
{
	key = al.get(i).toString();		
	CommonDataObject cd = (CommonDataObject) iMotivo.get(key);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
			<%=fb.hidden("key"+i,key)%> 
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("fecha_creacion"+i, cd.getColValue("fecha_creacion"))%>
			<%=fb.hidden("usuario_creacion"+i, cd.getColValue("usuario_creacion"))%>

<tr class="<%=color%>" align="center">
<td><%=_comp.getNombre()%></td>
<td><%//=fb.select(ConMgr.getConnection(),"SELECT codigo, descripcion||' - '||codigo, codigo FROM TBL_PLA_MOTIVO_FALTA ORDER  BY 1","forma", cd.getColValue("COD_GRUPO_DOSIS"),false,false,0,"",null,null)%>
		<%=fb.textBox("motivo"+i, cd.getColValue("motivo_falta"),false,false,true,5,"",null,null)%>
		<%=fb.textBox("descripcion"+i, cd.getColValue("descripcion"),false,false,true,35,"",null,null)%>
</td>
<td><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
</tr>
<%
}
fb.appendJsValidation("if(error>0)doAction();");
%>
<tr class="TextRow02">
						<td colspan="3" align="right">
								Opciones de Guardar: 
								<!---<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro --->
								<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
								<%=fb.radio("saveOption","C",false,false,false)%>Cerrar 
								<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
						</td>
					</tr>
					<%=fb.formEnd(true)%>
				</table>	
	<!-- TAB0 DIV END HERE-->
</div>
<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mSize",""+iMotivo.size())%>
<%=fb.hidden("iSize",""+iIncen.size())%>
<%=fb.hidden("sSize",""+iSueldo.size())%>
<%=fb.hidden("aSize",""+iAumento.size())%>
<%=fb.hidden("bSize",""+iBono.size())%>
<%=fb.hidden("motiLastLineNo",""+motiLastLineNo)%>
<%=fb.hidden("incenLastLineNo",""+incenLastLineNo)%>
<%=fb.hidden("sueldoLastLineNo",""+sueldoLastLineNo)%>
<%=fb.hidden("aumenLastLineNo",""+aumenLastLineNo)%>
<%=fb.hidden("bonoLastLineNo",""+bonoLastLineNo)%>
<tr class="TextHeader">
		<td>&nbsp;</td>
		<td colspan="2" align="center">Rango de ausencias </td>
		<td>&nbsp;</td><td>&nbsp;</td>
</tr>
<tr class="TextHeader" align="center">
	<td width="5%">&nbsp;</td>
	<td width="30%">Rango Inicial</td>
	<td width="30%">Rango Final</td>
	<td width="30%">Dias a pagar</td>
	<td width="5%"><%=fb.submit("agregar","+",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Incentivo")%></td>
</tr>
<%
al = CmnMgr.reverseRecords(iIncen);	
for (int i=0; i<iIncen.size(); i++)
{
	key = al.get(i).toString();		
	CommonDataObject cd = (CommonDataObject) iIncen.get(key);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
			<%=fb.hidden("key"+i,key)%> 
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("fecha_creacion"+i, cd.getColValue("fecha_creacion"))%>
			<%=fb.hidden("usuario_creacion"+i, cd.getColValue("usuario_creacion"))%>
<tr class="<%=color%>" align="center">
<td><%=(i+1)%></td>
<td><%=fb.intBox("rango_inicial"+i, cd.getColValue("rango_inicial"),true,false,false,3,2,null,null,"onBlur=\"javascript:chkNullValues(2)\"")%></td>
<td><%=fb.intBox("rango_final"+i, cd.getColValue("rango_final"),true,false,false,3,2,"",null,null)%></td>
<td><%=fb.intBox("dias_pagar"+i, cd.getColValue("dias_pagar"),true,false,false,3,2,"",null,null)%></td>
<td><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
</tr>
<%
}
//fb.appendJsValidation("\n\tif (!chkNullValues()) error++;\n");
fb.appendJsValidation("if(error>0)doAction();");
%>
<tr class="TextRow02">
						<td colspan="5" align="right">
								Opciones de Guardar: 
								<!---<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro --->
								<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
								<%=fb.radio("saveOption","C",false,false,false)%>Cerrar 
								<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
						</td>
					</tr>
					<%=fb.formEnd(true)%>
				</table>	
	<!-- TAB2 DIV END HERE-->
</div>
<!-- TAB3 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mSize",""+iMotivo.size())%>
<%=fb.hidden("iSize",""+iIncen.size())%>
<%=fb.hidden("sSize",""+iSueldo.size())%>
<%=fb.hidden("aSize",""+iAumento.size())%>
<%=fb.hidden("bSize",""+iBono.size())%>
<%=fb.hidden("motiLastLineNo",""+motiLastLineNo)%>
<%=fb.hidden("incenLastLineNo",""+incenLastLineNo)%>
<%=fb.hidden("sueldoLastLineNo",""+sueldoLastLineNo)%>
<%=fb.hidden("aumenLastLineNo",""+aumenLastLineNo)%>
<%=fb.hidden("bonoLastLineNo",""+bonoLastLineNo)%>

<tr class="TextHeader">
				<td colspan="5">Sobresueldos </td>
</tr>
<tr class="TextHeader" align="center">
	<td width="5%">&nbsp;</td>
	<td width="50%">Cargo o Funciòn</td>
	<td width="20%">Frecuencia</td>
	<td width="20%">Valor</td>
	<td width="5%"><%=fb.submit("agregar","+",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar SobreSueldo")%></td>
</tr>

<%
al = CmnMgr.reverseRecords(iSueldo);	
for (int i=0; i<iSueldo.size(); i++)
{
	key = al.get(i).toString();		
	CommonDataObject cd = (CommonDataObject) iSueldo.get(key);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
			<%=fb.hidden("key"+i,key)%> 
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("fecha_creacion"+i, cd.getColValue("fecha_creacion"))%>
			<%=fb.hidden("usuario_creacion"+i, cd.getColValue("usuario_creacion"))%>
			<%=fb.hidden("fecha_inicio"+i, cd.getColValue("fecha_inicio"))%>

<tr class="<%=color%>" align="center">
<td><%=(1+i)%></td>
<td><%=fb.textBox("cargo"+i, cd.getColValue("cargo"),false,false,true,5,"",null,null)%>
		<%=fb.textBox("denominacion"+i, cd.getColValue("denominacion"),false,false,true,35,"",null,null)%>
		 </td>
<td><%=fb.intBox("periodicidad"+i, cd.getColValue("periodicidad"),true,false,false,3,2,"",null,null)%></td>
<td><%=fb.decBox("valor"+i, cd.getColValue("valor"),true,false,false,3,5.2,"",null,null)%></td>
<td><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
</tr>
<%
}
fb.appendJsValidation("if(error>0)doAction();");
%>
<tr class="TextRow02">
						<td colspan="5" align="right">
								Opciones de Guardar: 
								<!---<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro --->
								<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
								<%=fb.radio("saveOption","C",false,false,false)%>Cerrar 
								<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
								<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
						</td>
					</tr>
					<%=fb.formEnd(true)%>
				</table>	
	<!-- TAB3 DIV END HERE-->
</div>

<div class="dhtmlgoodies_aTab">

<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","4")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mSize",""+iMotivo.size())%>
<%=fb.hidden("iSize",""+iIncen.size())%>
<%=fb.hidden("sSize",""+iSueldo.size())%>
<%=fb.hidden("aSize",""+iAumento.size())%>
<%=fb.hidden("bSize",""+iBono.size())%>
<%=fb.hidden("motiLastLineNo",""+motiLastLineNo)%>
<%=fb.hidden("incenLastLineNo",""+incenLastLineNo)%>
<%=fb.hidden("sueldoLastLineNo",""+sueldoLastLineNo)%>
<%=fb.hidden("aumenLastLineNo",""+aumenLastLineNo)%>
<%=fb.hidden("bonoLastLineNo",""+bonoLastLineNo)%>

			<tr class="TextRow02">
				<td colspan="5">&nbsp;</td>
			</tr>	
			<tr class="TextHeader">
				<td colspan="5">&nbsp;Tabla de Rangos de Aumentos por Convenci&oacute;n Colecctiva</td>
			</tr>
			<tr class="TextHeader">
				<td>&nbsp;</td>
				<td colspan="2" align="center">&nbsp;Años de Antiguedad</td>
				<td>&nbsp;</td><td align="center"><%=fb.submit("agregar","+",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Aumento")%></td>
			</tr>
			<tr class="TextHeader" align="center">
				<td width="20%">&nbsp;Año</td>
				<td width="20%">Rango Inicial</td>
				<td width="20%">Rango Final</td>
				<td width="30%">Cantidad a Aumentar</td>
				<td width="10%">&nbsp;</td>
			</tr>
			<%
al = CmnMgr.reverseRecords(iAumento);	
for (int i=0; i<iAumento.size(); i++)
{
	key = al.get(i).toString();		
	CommonDataObject cd = (CommonDataObject) iAumento.get(key);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
			<%=fb.hidden("key"+i,key)%> 
			<%=fb.hidden("remove"+i,"")%>
			<%=fb.hidden("fecha_creacion"+i, cd.getColValue("fecha_creacion"))%>
			<%=fb.hidden("usuario_creacion"+i, cd.getColValue("usuario_creacion"))%>

			<tr class="<%=color%>" align="center">
				<td><%=fb.intBox("anio"+i, cd.getColValue("anio"),true,false,false,5,4)%></td>
				<td><%=fb.intBox("rango_inicial"+i, cd.getColValue("rango_inicial"),true,false,false,5,2,null,null,"onBlur=\"javascript:chkNullValues(4)\"")%></td>
				<td><%=fb.intBox("rango_final"+i, cd.getColValue("rango_final"),false,false,false,5,2)%></td>
				<td><%=fb.decBox("monto"+i, cd.getColValue("monto"),false,false,false,5,2.2)%></td>
				<td><%=fb.submit("rem"+i,"X",false,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
		 </tr>
		<%
}
fb.appendJsValidation("if(error>0)doAction();");
%>			
			<tr class="TextRow02">
				<td colspan="5" align="right">
						Opciones de Guardar: 
						<!---<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro --->
						<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
						<%=fb.radio("saveOption","C",false,false,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
			</tr>
			<%=fb.formEnd(true)%>
		</table>	
</div>


<div class="dhtmlgoodies_aTab">

<table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","5")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mSize",""+iMotivo.size())%>
<%=fb.hidden("iSize",""+iIncen.size())%>
<%=fb.hidden("sSize",""+iSueldo.size())%>
<%=fb.hidden("aSize",""+iAumento.size())%>
<%=fb.hidden("bSize",""+iBono.size())%>
<%=fb.hidden("motiLastLineNo",""+motiLastLineNo)%>
<%=fb.hidden("incenLastLineNo",""+incenLastLineNo)%>
<%=fb.hidden("sueldoLastLineNo",""+sueldoLastLineNo)%>
<%=fb.hidden("aumenLastLineNo",""+aumenLastLineNo)%>
<%=fb.hidden("bonoLastLineNo",""+bonoLastLineNo)%>

			<tr class="TextRow02">
				<td colspan="4">&nbsp;</td>
			</tr>	
			<tr class="TextHeader">
				<td colspan="4">Tabla de Rangos de Bonificaci&oacute;n por Jubilaci&oacute;n o Pensi&oacute;n</td>
			</tr>
			<tr class="TextHeader">
				<td colspan="2" align="center">Años de Antiguedad</td>
				<td>&nbsp;</td>
				<td align="center"><%=fb.submit("agregar","+",false,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Medicamento")%></td>
			</tr>
			<tr class="TextRow01" align="center">
					<td width="30%">Desde</td>
					<td width="30%">Hasta</td>
					<td width="30%">Bonificaci&oacute;n</td>
					<td width="10%">&nbsp;</td>
			</tr>
<%
al = CmnMgr.reverseRecords(iBono);	
for (int i=0; i<iBono.size(); i++)
{
	key = al.get(i).toString();		
	CommonDataObject cd = (CommonDataObject) iBono.get(key);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
			<%=fb.hidden("key"+i,key)%> 
			<%=fb.hidden("remove"+i,"")%>
			<tr class="<%=color%>" align="center">
					<td><%=fb.decBox("rango_inicial"+i, cd.getColValue("rango_inicial"),false,false,false,10,10.2)%></td>
					<td><%=fb.decBox("rango_final"+i, cd.getColValue("rango_final"),false,false,false,10,10.2)%></td>
					<td><%=fb.decBox("bonificacion"+i, cd.getColValue("bonificacion"),false,false,false,10,10.2)%></td>
					<td><%=fb.submit("rem"+i,"X",false,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
			</tr>
<%
}
fb.appendJsValidation("if(error>0)doAction();");
%>
			<tr class="TextRow02">
				<td colspan="4" align="right">
						Opciones de Guardar: 
						<!---<%=fb.radio("saveOption","N",false,false,false)%>Crear Otro --->
						<%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
						<%=fb.radio("saveOption","C",false,false,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
			</tr>
			<%=fb.formEnd(true)%>
		</table>	
</div>
</div>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
<script type="text/javascript">
<%  
String tabLabel = "'Parámetros Generales'";
if (!mode.equalsIgnoreCase("add")) tabLabel += ",'Motivo de falta','Incentivo x asistencia','SobreSueldos','Aumento General','Bonificacion x jubilacion'";
%>
initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>
	</td>
</tr> 	
</table>

		
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET 
else
{
  
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	if(tab.equals("0")) //
	{
			 CommonDataObject cd = new CommonDataObject();
			 cd.setTableName("tbl_pla_parametros_cc");
			 cd.addColValue("cod_compania",(String)session.getAttribute("_companyId"));   
			 cd.addColValue("estado",request.getParameter("estado")); 
			 cd.addColValue("vigente_desde",request.getParameter("vigente"));   
			 cd.addColValue("vigente_hasta",request.getParameter("vigente_hasta")); 
			 cd.addColValue("subsidio_muerte",request.getParameter("subsidio"));   
			 cd.addColValue("descto_x_duelo",request.getParameter("duelo")); 
			 cd.addColValue("valor_x_alto_riesgo",request.getParameter("valor"));   
			 cd.addColValue("fecha_mod",cDateTime);
			 cd.addColValue("usuario_mod",(String)session.getAttribute("_userName"));
			 cd.addColValue("cantidad_max_cambio_turno",request.getParameter("cambio"));
			if (mode.equalsIgnoreCase("add"))
			{   
				 cd.addColValue("fecha_creacion",cDateTime); 
				 cd.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
				 SQLMgr.insert( cd);
			}
			else
			{
			   cd.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId"));
			   SQLMgr.update( cd);
			}
	}
	
	if(tab.equals("1")) //
	{
			
			int size = 0;
			if (request.getParameter("mSize") != null) size = Integer.parseInt(request.getParameter("mSize"));
			String itemRemoved = "";

			al.clear();
			for (int i=0; i<size; i++)
			{
				 CommonDataObject cd = new CommonDataObject();
				 cd.setTableName("tbl_pla_cc_param_sub_x_incap");
				 cd.setWhereClause("compania="+(String)session.getAttribute("_companyId")+"");
				 cd.addColValue("compania",(String)session.getAttribute("_companyId"));   
				 cd.addColValue("motivo_falta",request.getParameter("motivo"+i));   
				 cd.addColValue("descripcion",request.getParameter("descripcion"+i));   
				 cd.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));   
				 cd.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i)); 
				 cd.addColValue("fecha_mod",cDateTime);
				 cd.addColValue("usuario_mod",(String)session.getAttribute("_userName"));
				 cd.addColValue("key",request.getParameter("key"+i));
				 
				 if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
				 itemRemoved = cd.getColValue("key");  
				 else 
				 {
						try
						{
							iMotivo.put(cd.getColValue("key"),cd); 
							al.add(cd); 
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}
				}	
				 
			}//for
		if (!itemRemoved.equals(""))
		{
			vMotivo.remove(((CommonDataObject) iMotivo.get(itemRemoved)).getColValue("motivo_falta"));
    	iMotivo.remove(itemRemoved);
	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&id="+id+"&motiLastLineNo="+motiLastLineNo+"&incenLastLineNo="+incenLastLineNo+"&sueldoLastLineNo="+sueldoLastLineNo+"&aumenLastLineNo="+aumenLastLineNo+"&bonoLastLineNo="+bonoLastLineNo);
    	return;
		}

		if (baction != null && baction.equals("+"))
		{
	response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&type=1&mode="+mode+"&id="+id+"&motiLastLineNo="+motiLastLineNo+"&incenLastLineNo="+incenLastLineNo+"&sueldoLastLineNo="+sueldoLastLineNo+"&aumenLastLineNo="+aumenLastLineNo+"&bonoLastLineNo="+bonoLastLineNo);
    	return;
		}
		if (al.size() == 0)
		{
			CommonDataObject cd = new CommonDataObject();
			cd.setTableName("tbl_pla_cc_param_sub_x_incap");
			cd.setWhereClause("compania="+id+"");
			al.add(cd); 
		}
		SQLMgr.insertList(al);
			
	}
	if(tab.equals("2")) //
	{
			
			int size = 0;
			if (request.getParameter("iSize") != null) size = Integer.parseInt(request.getParameter("iSize"));
			String itemRemoved = "";
			al.clear();
			for (int i=0; i<size; i++)
			{
				 CommonDataObject cd = new CommonDataObject();
				 cd.setTableName("tbl_pla_cc_param_inc_x_asist");
				 
				 cd.setWhereClause("compania="+(String)session.getAttribute("_companyId")+"");
				 cd.addColValue("compania",(String)session.getAttribute("_companyId"));   
				 cd.addColValue("rango_inicial",request.getParameter("rango_inicial"+i));   
				 cd.addColValue("rango_final",request.getParameter("rango_final"+i));   
				 cd.addColValue("dias_pagar",request.getParameter("dias_pagar"+i));   
				 cd.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));   
				 cd.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i)); 
				 cd.addColValue("fecha_mod",cDateTime);
				 cd.addColValue("usuario_mod",(String)session.getAttribute("_userName"));
				 cd.addColValue("key",request.getParameter("key"+i));
				 
				 if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
				 itemRemoved = cd.getColValue("key");  
				 else 
				 {
						try
						{
							iIncen.put(cd.getColValue("key"),cd); 
							al.add(cd); 
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}
				}	
				 
			}//for
		if (!itemRemoved.equals(""))
		{
    	iIncen.remove(itemRemoved);
	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&id="+id+"&motiLastLineNo="+motiLastLineNo+"&incenLastLineNo="+incenLastLineNo+"&sueldoLastLineNo="+sueldoLastLineNo+"&aumenLastLineNo="+aumenLastLineNo+"&bonoLastLineNo="+bonoLastLineNo);
    	return;
		}

		if(baction.equals("+"))
		{
			CommonDataObject cd = new CommonDataObject();
			cd.addColValue("rango_inicial","");
			cd.addColValue("fecha_creacion",cDateTime);   
			cd.addColValue("usuario_creacion",(String)session.getAttribute("_userName"));
			incenLastLineNo++;
			if (incenLastLineNo < 10) key = "00" + incenLastLineNo;
			else if (incenLastLineNo < 100) key = "0" + incenLastLineNo;
			else key = "" + incenLastLineNo;
			iIncen.put(key,cd);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&id="+id+"&motiLastLineNo="+motiLastLineNo+"&incenLastLineNo="+incenLastLineNo+"&sueldoLastLineNo="+sueldoLastLineNo+"&aumenLastLineNo="+aumenLastLineNo+"&bonoLastLineNo="+bonoLastLineNo);
			return;
		}
		if (al.size() == 0)
		{
			CommonDataObject cd = new CommonDataObject();
			cd.setTableName("tbl_pla_cc_param_inc_x_asist");
			cd.setWhereClause("compania="+(String)session.getAttribute("_companyId")+"");
			al.add(cd); 
		}
		SQLMgr.insertList(al);
			
	}
	if(tab.equals("3")) //
	{
			int size = 0;
			if (request.getParameter("sSize") != null) size = Integer.parseInt(request.getParameter("sSize"));
			String itemRemoved = "";
	
			al.clear();
			for (int i=0; i<size; i++)
			{
				 CommonDataObject cd = new CommonDataObject();
				 cd.setTableName("tbl_pla_cc_param_sobresueldos");
				 cd.setWhereClause("compania="+(String)session.getAttribute("_companyId")+"");
				 cd.addColValue("compania",(String)session.getAttribute("_companyId"));   
				 cd.addColValue("cargo",request.getParameter("cargo"+i));   
				 cd.addColValue("periodicidad",request.getParameter("periodicidad"+i));   
				 cd.addColValue("valor",request.getParameter("valor"+i)); 
				 cd.addColValue("denominacion",request.getParameter("denominacion"+i));   
				 cd.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));   
				 cd.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i)); 
				 cd.addColValue("fecha_mod",cDateTime);
				 cd.addColValue("usuario_mod",(String)session.getAttribute("_userName"));
				 cd.addColValue("fecha_inicio",request.getParameter("fecha_inicio"+i)); 
				 cd.addColValue("key",request.getParameter("key"+i));
				  
				 if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
				 itemRemoved = cd.getColValue("key");  
				 else 
				 {
						try
						{
							iSueldo.put(cd.getColValue("key"),cd); 
							al.add(cd); 
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}
				}	
				 
			}//for
		if (!itemRemoved.equals(""))
		{
    	vCargo.remove(((CommonDataObject) iSueldo.get(itemRemoved)).getColValue("cargo"));
			iSueldo.remove(itemRemoved);
	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&id="+id+"&motiLastLineNo="+motiLastLineNo+"&incenLastLineNo="+incenLastLineNo+"&sueldoLastLineNo="+sueldoLastLineNo+"&aumenLastLineNo="+aumenLastLineNo+"&bonoLastLineNo="+bonoLastLineNo);
    	return;
		}

		if(baction.equals("+"))
		{
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&type=2&tab=3&mode="+mode+"&id="+id+"&motiLastLineNo="+motiLastLineNo+"&incenLastLineNo="+incenLastLineNo+"&sueldoLastLineNo="+sueldoLastLineNo+"&aumenLastLineNo="+aumenLastLineNo+"&bonoLastLineNo="+bonoLastLineNo);
			return;
		}
		if (al.size() == 0)
		{
			CommonDataObject cd = new CommonDataObject();
			cd.setTableName("tbl_pla_cc_param_sobresueldos");
			cd.setWhereClause("compania="+(String)session.getAttribute("_companyId")+"");
			al.add(cd); 
		}
		SQLMgr.insertList(al);
			
	}
	if(tab.equals("4")) //
	{
			int size = 0;
			if (request.getParameter("aSize") != null) size = Integer.parseInt(request.getParameter("aSize"));
			String itemRemoved = "";
	
			al.clear();
			for (int i=0; i<size; i++)
			{
				 CommonDataObject cd = new CommonDataObject();
				 cd.setTableName("tbl_pla_cc_rango_aumentos");
				 
				 cd.setWhereClause("compania="+(String)session.getAttribute("_companyId")+"");
				 cd.addColValue("compania",(String)session.getAttribute("_companyId")); 
				 cd.addColValue("anio",request.getParameter("anio"+i));   
				 cd.addColValue("rango_inicial",request.getParameter("rango_inicial"+i));   
				 cd.addColValue("rango_final",request.getParameter("rango_final"+i));   
				 cd.addColValue("monto",request.getParameter("monto"+i));   
				 cd.addColValue("fecha_creacion",request.getParameter("fecha_creacion"+i));   
				 cd.addColValue("usuario_creacion",request.getParameter("usuario_creacion"+i)); 
				 cd.addColValue("fecha_mod",cDateTime);
				 cd.addColValue("usuario_mod",(String)session.getAttribute("_userName"));
				 cd.addColValue("key",request.getParameter("key"+i));
			
				 if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
				 itemRemoved = cd.getColValue("key");  
				 else 
				 {
						try
						{
							iAumento.put(cd.getColValue("key"),cd); 
							al.add(cd); 
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}
				}	
				 
			}//for
		if (!itemRemoved.equals(""))
		{
    	iAumento.remove(itemRemoved);
	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&mode="+mode+"&id="+id+"&motiLastLineNo="+motiLastLineNo+"&incenLastLineNo="+incenLastLineNo+"&sueldoLastLineNo="+sueldoLastLineNo+"&aumenLastLineNo="+aumenLastLineNo+"&bonoLastLineNo="+bonoLastLineNo);
    	return;
		}

		if(baction.equals("+"))
		{
			CommonDataObject cd = new CommonDataObject();
			cd.addColValue("anio","");
			cd.addColValue("rango_inicial","");
			cd.addColValue("fecha_creacion",cDateTime);   
			cd.addColValue("usuario_creacion",(String)session.getAttribute("_userName"));
			aumenLastLineNo++;
			if (aumenLastLineNo < 10) key = "00" + aumenLastLineNo;
			else if (aumenLastLineNo < 100) key = "0" + aumenLastLineNo;
			else key = "" + aumenLastLineNo;
			iAumento.put(key,cd);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&mode="+mode+"&id="+id+"&motiLastLineNo="+motiLastLineNo+"&incenLastLineNo="+incenLastLineNo+"&sueldoLastLineNo="+sueldoLastLineNo+"&aumenLastLineNo="+aumenLastLineNo+"&bonoLastLineNo="+bonoLastLineNo);
			return;
		}
		if (al.size() == 0)
		{
			CommonDataObject cd = new CommonDataObject();
			cd.setTableName("tbl_pla_cc_rango_aumentos");
			cd.setWhereClause("compania="+(String)session.getAttribute("_companyId")+"");
			al.add(cd); 
		}
		SQLMgr.insertList(al);
			
	}
	if(tab.equals("5")) //
	{
			int size = 0;
			if (request.getParameter("bSize") != null) size = Integer.parseInt(request.getParameter("bSize"));
			String itemRemoved = "";
	
			al.clear();
			for (int i=0; i<size; i++)
			{
				 CommonDataObject cd = new CommonDataObject();
				 cd.setTableName("tbl_pla_rango_bonif_jub");
				
				 cd.setWhereClause("compania="+(String)session.getAttribute("_companyId")+"");
				 cd.addColValue("compania",(String)session.getAttribute("_companyId")); 
				 cd.addColValue("rango_inicial",request.getParameter("rango_inicial"+i));   
				 cd.addColValue("rango_final",request.getParameter("rango_final"+i));   
				 cd.addColValue("bonificacion",request.getParameter("bonificacion"+i));   
				 cd.addColValue("key",request.getParameter("key"+i));
			
				 if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
				 itemRemoved = cd.getColValue("key");  
				 else 
				 {
						try
						{
							iBono.put(cd.getColValue("key"),cd); 
							al.add(cd); 
						}
						catch(Exception e)
						{
							System.err.println(e.getMessage());
						}
				}	
				 
			}//for
		if (!itemRemoved.equals(""))
		{
    	iBono.remove(itemRemoved);
	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=5&mode="+mode+"&id="+id+"&motiLastLineNo="+motiLastLineNo+"&incenLastLineNo="+incenLastLineNo+"&sueldoLastLineNo="+sueldoLastLineNo+"&aumenLastLineNo="+aumenLastLineNo+"&bonoLastLineNo="+bonoLastLineNo);
    	return;
		}

		if(baction.equals("+"))
		{
			CommonDataObject cd = new CommonDataObject();
			cd.addColValue("rango_inicial","");
			bonoLastLineNo++;
			if (bonoLastLineNo < 10) key = "00" + bonoLastLineNo;
			else if (bonoLastLineNo < 100) key = "0" + bonoLastLineNo;
			else key = "" + bonoLastLineNo;
			iBono.put(key,cd);
			response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=5&mode="+mode+"&id="+id+"&motiLastLineNo="+motiLastLineNo+"&incenLastLineNo="+incenLastLineNo+"&sueldoLastLineNo="+sueldoLastLineNo+"&aumenLastLineNo="+aumenLastLineNo+"&bonoLastLineNo="+bonoLastLineNo);
			return;
		}
		if (al.size() == 0)
		{
			CommonDataObject cd = new CommonDataObject();
			cd.setTableName("tbl_pla_rango_bonif_jub");
			cd.setWhereClause("compania="+(String)session.getAttribute("_companyId")+"");
			al.add(cd); 
		}
		SQLMgr.insertList(al);
			
	}
	
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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/estadovacaciones_list.jsp"))
	{
%>
	//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/estadovacaciones_list.jsp")%>';
<%
	}
	else
	{
%>
	//window.location = '<%=request.getContextPath()%>/rhplanilla/convencion_config.jsp';
<%
	}
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?&mode=edit&tab=<%=tab%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
