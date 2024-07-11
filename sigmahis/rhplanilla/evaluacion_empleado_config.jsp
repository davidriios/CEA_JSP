<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.rhplanilla.EvalEmpleado"%>
<%@ page import="issi.rhplanilla.FactoresEval"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iFact" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vFact" scope="session" class="java.util.Vector" />
<jsp:useBean id="iMat" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iLim" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="EvalMgr" scope="page" class="issi.rhplanilla.EvaluacionMgr"/>
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

CommonDataObject emp = new CommonDataObject();
EvalEmpleado eval = new EvalEmpleado();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
EvalMgr.setConnection(ConMgr);
ArrayList al = new ArrayList();

String key = "";
String sql = "";
int tab =0;
String mode = request.getParameter("mode");
String prov = request.getParameter("prov");
String sigla = request.getParameter("sigla");
String tomo = request.getParameter("tomo");
String asiento = request.getParameter("asiento");
String emp_id = request.getParameter("emp_id");
String id = request.getParameter("id");
String change = request.getParameter("change");
String fg = request.getParameter("fg");
String total = "0";
String fechaEvaluacion = "";
String periodoEvdesde = "";
String periodoEvhasta = "";
String codigo = "";
int factLastLineNo = 0;
int matLastLineNo = 0;
int limLastLineNo = 0;

if (mode == null) mode = "add";
if (fg == null) fg = "";
if(request.getParameter("tab")!=null) tab = Integer.parseInt(request.getParameter("tab"));
if (request.getParameter("factLastLineNo") != null) factLastLineNo = Integer.parseInt(request.getParameter("factLastLineNo"));
if (request.getParameter("matLastLineNo") != null) matLastLineNo = Integer.parseInt(request.getParameter("matLastLineNo"));
if (request.getParameter("limLastLineNo") != null) limLastLineNo = Integer.parseInt(request.getParameter("limLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
		id = "0";
		
		iFact.clear();
		vFact.clear();
		iMat.clear();
		iLim.clear();
		
		fechaEvaluacion = CmnMgr.getCurrentDate("dd/mm/yyyy");
		periodoEvdesde = CmnMgr.getCurrentDate("dd/mm/yyyy");
		periodoEvhasta = CmnMgr.getCurrentDate("dd/mm/yyyy");
		codigo = "0";
		sql = "SELECT  b.codigo as factor, b.descripcion, b.valor_min as valorMin, b.valor_max as valorMax FROM tbl_pla_factores b order by b.codigo";
			al = sbb.getBeanList(ConMgr.getConnection(),sql,FactoresEval.class);
			System.out.println("Sql:\n"+sql);
			iFact.clear();
			factLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				FactoresEval fa = (FactoresEval) al.get(i-1);
				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				fa.setKey(key);
				try
				{
					iFact.put(key,fa);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}  	
	}
	else
	{
		if (prov == null || sigla == null || tomo == null || asiento == null || emp_id == null) throw new Exception("El Código del Empleado no es válido. Por favor intente nuevamente!");

		sql="SELECT a.codigo, a.provincia, a.sigla, a.tomo, a.asiento, a.compania, b.primer_nombre||decode(b.segundo_nombre,null,'',''||b.segundo_nombre)||''||b.primer_apellido||decode(b.segundo_apellido,null,'',''||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_casada,null,'',''||b.apellido_casada)) as nombre, b.cargo, a.unidad_adm as unidadAdm, b.depto, nvl(b.num_empleado,'') as numEmpleado, b.fechaIngreso, b.fechaPuestoact, nvl(a.tipo_evaluacion,'') as tipoEvaluacion, c.descripcion as tipoEvaluacionDesc, to_char(a.fecha_evaluacion,'dd/mm/yyyy') as fechaEvaluacion, to_char(a.periodo_evdesde,'dd/mm/yyyy') as periodoEvdesde, to_char(a.periodo_evhasta,'dd/mm/yyyy') as periodoEvhasta, a.provincia_eval as provinciaEval, a.sigla_eval as siglaEval, a.tomo_eval as tomoEval, a.asiento_eval as asientoEval, d.primer_nombre||decode(d.segundo_nombre,null,'',''||d.segundo_nombre)||''||d.primer_apellido||decode(d.segundo_apellido,null,'',''||d.segundo_apellido)||decode(d.sexo,'F',decode(d.apellido_casada,null,'',''||d.apellido_casada))as evaluadorDesc, a.responsabilidades, decode(a.puntaje_total,null,0,a.puntaje_total) as puntajeTotal, nvl(a.calificacion,'') as calificacion, nvl(a.comentario_empleado,'') as comentarioEmpleado, nvl(a.observaciones_evaluador,'') as observacionesEvaluador, a.acepto_empleado as aceptoEmpleado FROM tbl_pla_evaluacion a, (SELECT a.primer_nombre, a.segundo_nombre, a.primer_apellido, a.segundo_apellido, a.apellido_casada, a.provincia, a.sigla, a.tomo, a.asiento, a.num_empleado, a.cargo, b.descripcion as depto, a.sexo, to_char(a.fecha_ingreso,'dd/mm/yyyy') as fechaIngreso,  nvl(to_char(a.fecha_puestoact,'dd/mm/yyyy'),'') as fechaPuestoact, a.emp_id FROM tbl_pla_empleado a, tbl_sec_unidad_ejec b WHERE a.compania="+(String) session.getAttribute("_companyId")+" and a.unidad_organi=b.codigo and a.compania=b.compania) b, tbl_pla_tipo_evaluacion c, tbl_pla_empleado d WHERE a.tipo_evaluacion=c.codigo(+) and a.compania=d.compania and a.emp_id=d.emp_id and a.compania=d.compania and a.emp_id = b.emp_id and a.compania="+(String) session.getAttribute("_companyId")+" and a.emp_id="+emp_id+" and a.codigo="+id;
		eval = (EvalEmpleado) sbb.getSingleRowBean(ConMgr.getConnection(),sql,EvalEmpleado.class);
		System.out.println("sql:\n"+sql);
		fechaEvaluacion = eval.getFechaEvaluacion();
		periodoEvdesde = eval.getPeriodoEvdesde();
		periodoEvhasta = eval.getPeriodoEvhasta();
		codigo = eval.getCodigo();
        total = eval.getPuntajeTotal();
		
		if (change == null)
		{
			iFact.clear();
			vFact.clear();
			iMat.clear();
			iLim.clear();
			
			sql = "SELECT a.provincia, a.sigla, a.tomo, a.asiento, a.evaluacion, b.codigo as factor, b.descripcion, a.valor, b.valor_min as valorMin, b.valor_max as valorMax FROM tbl_pla_factores_ev a, tbl_pla_factores b WHERE a.factor(+)=b.codigo and a.compania(+)="+(String) session.getAttribute("_companyId")+" and a.emp_id(+)="+emp_id+" and a.evaluacion(+)="+id+" order by b.codigo";
			al = sbb.getBeanList(ConMgr.getConnection(),sql,FactoresEval.class);
			
			factLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				FactoresEval fa = (FactoresEval) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				fa.setKey(key);

				try
				{
					iFact.put(key,fa);
					vFact.addElement(fa.getFactor());
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}  	
			
			sql = "SELECT evaluacion, codigo, provincia, sigla, tomo, asiento, compania, descripcion FROM tbl_pla_materias_mejorar WHERE compania="+(String) session.getAttribute("_companyId")+" and emp_id="+emp_id+" and evaluacion="+id;		
			al = sbb.getBeanList(ConMgr.getConnection(),sql,FactoresEval.class);
			
			
			matLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				FactoresEval fac = (FactoresEval) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				fac.setKey(key);

				try
				{
					iMat.put(key,fac);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			} 
			
			sql = "SELECT compania, provincia, sigla, tomo, asiento, evaluacion, codigo, descripcion FROM tbl_pla_limitacion WHERE compania="+(String) session.getAttribute("_companyId")+" and  emp_id="+emp_id+" and evaluacion="+id;
			al = sbb.getBeanList(ConMgr.getConnection(),sql,FactoresEval.class);
			
			
			limLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++)
			{
				FactoresEval fac = (FactoresEval) al.get(i-1);
				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				fac.setKey(key);

				try
				{
					iLim.put(key,fac);
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
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp"%>
<script language="javascript">
document.title = 'Evaluación del Empleado -  Edición - '+document.title;
function addEmpleado()
{
    abrir_ventana1('../common/search_empleado.jsp?fp=evaluacion_empleado&fg=<%=fg%>');
}
function addMotivo()
{
    abrir_ventana1('../common/search_tipo_evaluacion.jsp?fp=evaluacion_empleado');
}
function addEvaluador()
{
    abrir_ventana1('../common/search_empleado.jsp?fp=evaluador');
}

function sumPuntaje()
{
   var count = 0; 
   var valor = 0;
   var valorMin = 0;
   var valorMax = 0;   
   
   <%
      for (int i = 1; i <= iFact.size(); i++)
	  {         
   %>
         valorMin = parseInt((eval('document.form0.valorMin'+<%=i%>).value),10);
		 		 valorMax = parseInt((eval('document.form0.valorMax'+<%=i%>).value),10);
         valor = parseInt((eval('document.form0.valor'+<%=i%>).value),10);
         if (valor==0 || (valor>=valorMin && valor<=valorMax))
         count = count + valor; 
         else
		 {
		   alert('Valor Fuera del Rango !');
		   return;
		 }  
   <%
      }
   %>   
  document.form0.puntajeTotal.value = count;
}
function sumMethod()
{
   sumPuntaje();
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" >
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RHPLANILLA - MANTENIMIENTO - EVALUACIÓN EMPLEADO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">


<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("factSize",""+iFact.size())%>
<%=fb.hidden("factLastLineNo",""+factLastLineNo)%>
<%=fb.hidden("matSize",""+iMat.size())%>
<%=fb.hidden("matLastLineNo",""+matLastLineNo)%>
<%=fb.hidden("limSize",""+iLim.size())%>
<%=fb.hidden("limLastLineNo",""+limLastLineNo)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Empleado</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">								
							<tr class="TextRow01">
								<td width="10%">Empleado</td>
							    <td width="40%"><%=fb.textBox("nombre",eval.getNombre(),true,false,true,47)%><%=fb.button("btnEmpleado","...",true,mode.equals("edit"),null,null,"onClick=\"javascript:addEmpleado()\"")%></td>														
								<td width="8%">C&eacute;dula</td>
							    <td width="27%"><%=fb.textBox("provincia",eval.getProvincia(),true,false,true,3)%><%=fb.textBox("sigla",eval.getSigla(),true,false,true,3)%><%=fb.textBox("tomo",eval.getTomo(),true,false,true,5)%><%=fb.textBox("asiento",eval.getAsiento(),true,false,true,5)%></td>
								<td width="5%">No:</td>
								<td width="8%"><%=fb.textBox("numEmpleado",eval.getNumEmpleado(),false,false,true,5)%></td>							
						    </tr>					
							<tr class="TextRow01">
								<td>Cargo</td>
								<td><%=fb.textBox("cargo",eval.getCargo(),true,false,true,47)%></td>
								<td colspan="4">Fecha Ingr. a la Empresa&nbsp;&nbsp;&nbsp;&nbsp;<%=fb.textBox("fechaIngreso",eval.getFechaIngreso(),false,false,true,20)%></td>													
							</tr>	
							<tr class="TextRow01">
								<td>Depto.</td><%=fb.hidden("unidadAdm",eval.getUnidadAdm())%>
								<td><%=fb.textBox("depto",eval.getDepto(),false,false,true,47)%></td>
								<td colspan="4">Fecha Ingr. al Cargo Actual&nbsp;<%=fb.textBox("fechaPuestoact",eval.getFechaPuestoact(),false,false,true,20)%></td>													
							</tr>																	
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Datos Generales de la Evaluación</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">	
							<tr class="TextRow01">
								<td width="12%">Eval No.</td>
								<td width="44%"><%=fb.intBox("codigo",codigo,false,false,true,10)%></td>
								<td width="14%">Fecha Eval.</td>
								<td width="30%"><jsp:include page="../common/calendar.jsp" flush="true">
												<jsp:param name="noOfDateTBox" value="1" />
												<jsp:param name="clearOption" value="true" />
												<jsp:param name="nameOfTBox1" value="fechaEvaluacion" />
												<jsp:param name="valueOfTBox1" value="<%=fechaEvaluacion%>" />
												</jsp:include></td>																	
							</tr>
							<tr class="TextRow01">
								<td>Motivo Evaluaci&oacute;n</td>
								<td><%=fb.intBox("tipoEvaluacion",eval.getTipoEvaluacion(),false,false,true,5)%><%=fb.textBox("tipoEvaluacionDesc",eval.getTipoEvaluacionDesc(),false,false,true,40)%><%=fb.button("btnMotivo","...",false,false,null,null,"onClick=\"javascript:addMotivo()\"")%></td>
								<td>Periodo Eval. Del:</td>
								<td><jsp:include page="../common/calendar.jsp" flush="true">
												<jsp:param name="noOfDateTBox" value="1" />
												<jsp:param name="clearOption" value="true" />
												<jsp:param name="nameOfTBox1" value="periodoEvdesde" />
												<jsp:param name="valueOfTBox1" value="<%=periodoEvdesde%>" />
												</jsp:include>
										&nbsp;Al:&nbsp;<jsp:include page="../common/calendar.jsp" flush="true">
												<jsp:param name="noOfDateTBox" value="1" />
												<jsp:param name="clearOption" value="true" />
												<jsp:param name="nameOfTBox1" value="periodoEvhasta" />
												<jsp:param name="valueOfTBox1" value="<%=periodoEvhasta%>" />
												</jsp:include></td>
							</tr>	
							<tr class="TextRow01">
								<td>Evaluador</td>
								<td colspan="3"><%=fb.textBox("provinciaEval",eval.getProvinciaEval(),true,false,true,3)%><%=fb.textBox("siglaEval",eval.getSiglaEval(),true,false,true,3)%><%=fb.textBox("tomoEval",eval.getTomoEval(),true,false,true,5)%><%=fb.textBox("asientoEval",eval.getAsientoEval(),true,false,true,5)%>&nbsp;<%=fb.textBox("evaluadorDesc",eval.getEvaluadorDesc(),true,false,true,75)%><%=fb.button("btnEvaluador","...",false,false,null,null,"onClick=\"javascript:addEvaluador()\"")%></td>
							</tr>
							<tr class="TextRow01">
								<td>Responsabilidades</td>
								<td colspan="3"><%=fb.textarea("responsabilidades",eval.getResponsabilidades(),false,false,false,86,4)%></td>
							</tr>							
						</table>
					</td>
				</tr>
				
			<tr>	<td onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Detalle de Factores a Evaluar</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				
				<tr id="panel2">
					<td width="100%">
					<table width="100%" cellpadding="1" cellspacing="1">
					<tr class="TextHeader" align="center">
					<td width="15%">C&oacute;digo</td>
					<td width="60%">Descripci&oacute;n</td>							
					<td width="15%" align="left">Calificaci&oacute;n</td>					
				</tr>			
				<%	
				    al = CmnMgr.reverseRecords(iFact);				
				    for (int i = 1; i <= iFact.size(); i++)
				    {
					  key = al.get(i - 1).toString();	
					  String color = "TextRow02";
						if (i % 2 == 0) color = "TextRow01";
					  FactoresEval fa = (FactoresEval) iFact.get(key);
					  if (fa.getValor() == null || fa.getValor().equalsIgnoreCase("")) fa.setValor(fa.getValorMin());  					  
			    %>		
				<%=fb.hidden("remove"+i,"")%>
				<%=fb.hidden("valorMin"+i,fa.getValorMin())%>
				<%=fb.hidden("valorMax"+i,fa.getValorMax())%>	
				<%=fb.hidden("key"+i,key)%>
				<%=fb.hidden("descripcion"+i,fa.getDescripcion())%>
				<%=fb.hidden("factor"+i,fa.getFactor())%>
				<tr class="<%=color%>">
					<td align="center"><%=fa.getFactor()%></td>
					<td><%=fa.getDescripcion()%></td>        
					<td align="left"><%=fb.decBox("valor"+i,fa.getValor(),true,false,false,10,3.2,null,null,"onBlur=\"javascript:sumPuntaje()\"")%>&nbsp;(<%=fa.getValorMin()%> - <%=fa.getValorMax()%>)</td>					
				</tr>
				<%	 
					}
				%> 
				<tr class="TextRow01">
					    <td align="right" colspan="2">Puntaje Total&nbsp;&nbsp;</td>
							<td align="left"><%=fb.decBox("puntajeTotal",total,false,false,true,10,3.2,null,null,"onBlur=\"javascript:sumMethod()\"")%></td>
				</tr>
					</table>
				</td>
				</tr>	
			
						
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
            <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
            <%=fb.radio("saveOption","C")%>Cerrar 
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB0 DIV END HERE-->
</div>

<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("provincia",prov)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("factSize",""+iFact.size())%>
<%=fb.hidden("factLastLineNo",""+factLastLineNo)%>
<%=fb.hidden("matSize",""+iMat.size())%>
<%=fb.hidden("matLastLineNo",""+matLastLineNo)%>
<%=fb.hidden("limSize",""+iLim.size())%>
<%=fb.hidden("limLastLineNo",""+limLastLineNo)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
				
                <tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Empleado</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
				    <td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow01">
								<td width="15%">Nombre Empleado</td>
								<td width="48%"><%=fb.textBox("nombre",eval.getNombre(),false,false,true,60)%></td>
								<td width="9%">C&eacute;dula</td>
							    <td width="28%"><%=fb.textBox("provincia",eval.getProvincia(),false,false,true,3)%><%=fb.textBox("sigla",eval.getSigla(),false,false,true,3)%><%=fb.textBox("tomo",eval.getTomo(),false,false,true,5)%><%=fb.textBox("asiento",eval.getAsiento(),false,false,true,5)%></td>
							</tr>
						</table>
					</td>			
				</tr>
				<tr>
					<td onClick="javascript:showHide(12)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Materias a Mejorar</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus12" style="display:none">+</label><label id="minus12">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel12">
					<td width="100%">
					<table width="100%" cellpadding="1" cellspacing="1">
					<tr class="TextHeader" align="center">
					<td width="20%">C&oacute;digo</td>
					<td width="70%">Descripci&oacute;n</td>								
					<td width="10%"><%=fb.submit("addCol","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
				</tr>			
				<%	
				    	  
				    al = CmnMgr.reverseRecords(iMat);				
				    for (int i = 1; i <= iMat.size(); i++)
				    {
						 String color = "TextRow02";
						if (i % 2 == 0) color = "TextRow01";
					  key = al.get(i - 1).toString();									  
						FactoresEval fact =	(FactoresEval)iMat.get(key);				  					  
			    %>		
				 <tr class="<%=color%>" align="center">
				 <%=fb.hidden("key"+i,key)%>
				 <%=fb.hidden("remove"+i,"")%>
				 <%=fb.hidden("codigo"+i,fact.getCodigo())%>	
					 <td><%=fact.getCodigo()%></td>
					 <td><%=fb.textBox("descripcion"+i,fact.getDescripcion(),true,false,false,90,100)%></td>        
					 <td><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%>		</td>					
				 </tr>
				<%					     
					}
				%>  				 	
					</table>
					</td>
				</tr>
				
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
            <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
            <%=fb.radio("saveOption","C")%>Cerrar 
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB1 DIV END HERE-->
</div>


<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("provincia",prov)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("factSize",""+iFact.size())%>
<%=fb.hidden("factLastLineNo",""+factLastLineNo)%>
<%=fb.hidden("matSize",""+iMat.size())%>
<%=fb.hidden("matLastLineNo",""+matLastLineNo)%>
<%=fb.hidden("limSize",""+iLim.size())%>
<%=fb.hidden("limLastLineNo",""+limLastLineNo)%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
        <tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Empleado</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
				   <td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow01">
								<td width="15%">Nombre Empleado</td>
								<td width="48%"><%=fb.textBox("nombre",eval.getNombre(),false,false,true,60)%></td>
								<td width="9%">C&eacute;dula</td>
							    <td width="28%"><%=fb.textBox("provincia",eval.getProvincia(),false,false,true,3)%><%=fb.textBox("sigla",eval.getSigla(),false,false,true,3)%><%=fb.textBox("tomo",eval.getTomo(),false,false,true,5)%><%=fb.textBox("asiento",eval.getAsiento(),false,false,true,5)%></td>
							</tr>
						</table>
					</td>			
				</tr>
				<tr>
					<td onClick="javascript:showHide(22)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Limitaciones Encontradas</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus22" style="display:none">+</label><label id="minus22">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel22">
					<td width="100%">
					<table width="100%" cellpadding="1" cellspacing="1">
					<tr class="TextHeader" align="center">
					<td width="20%">C&oacute;digo</td>
					<td width="70%">Descripci&oacute;n</td>								
					<td width="10%"><%=fb.submit("addCol","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
				</tr>			
				<%	
				    al = CmnMgr.reverseRecords(iLim);				
				    for (int i = 1; i <= iLim.size(); i++)
				    {
							String color = "TextRow02";
							if (i % 2 == 0) color = "TextRow01";
					    key = al.get(i - 1).toString();									  
							FactoresEval fLim =	(FactoresEval)iLim.get(key);						  					  
			    %>		
				 <tr class="<%=color%>" align="center">
				 <%=fb.hidden("key"+i,key)%>
				 <%=fb.hidden("remove"+i,"")%>	
				 <%=fb.hidden("codigo"+i,fLim.getCodigo())%>
					 <td><%=fLim.getCodigo()%></td>
					 <td><%=fb.textBox("descripcion"+i,fLim.getDescripcion(),true,false,false,85,100)%></td>        
					 <td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"")%>							
				 </tr>
				<%					     
					}
				%> 
					</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
            <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
            <%=fb.radio("saveOption","C")%>Cerrar 
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
		</table>
<!-- TAB2 DIV END HERE-->
</div>
<!-- TAB3 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
				<table align="center" width="100%" cellpadding="0" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("emp_id",emp_id)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("factSize",""+iFact.size())%>
<%=fb.hidden("factLastLineNo",""+factLastLineNo)%>
<%=fb.hidden("matSize",""+iMat.size())%>
<%=fb.hidden("matLastLineNo",""+matLastLineNo)%>
<%=fb.hidden("limSize",""+iLim.size())%>
<%=fb.hidden("limLastLineNo",""+limLastLineNo)%>
<%=fb.hidden("provincia",prov)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("sigla",sigla)%>


				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>
        <tr>
					<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Empleado</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel30">
				    <td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow01">
								<td width="15%">Nombre Empleado</td>
								<td width="48%"><%=fb.textBox("nombre",eval.getNombre(),false,false,true,60)%></td>
								<td width="9%">C&eacute;dula</td>
							    <td width="28%"><%=fb.textBox("provincia",eval.getProvincia(),false,false,true,3)%><%=fb.textBox("sigla",eval.getSigla(),false,false,true,3)%><%=fb.textBox("tomo",eval.getTomo(),false,false,true,5)%><%=fb.textBox("asiento",eval.getAsiento(),false,false,true,5)%></td>
							</tr>
						</table>
					</td>			
				</tr>
				<tr>
					<td onClick="javascript:showHide(31)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Resultado de la Evaluaci&oacute;n</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus31" style="display:none">+</label><label id="minus31">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel31">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow01">
								<td width="10%">Evaluaci&oacute;n</td>
								<td width="15%"><%=fb.textBox("codigo",codigo,false,false,true,10)%></td>
								<td width="10%">Puntaje</td>
								<td width="15%"><%=fb.decBox("puntajeTotal",eval.getPuntajeTotal(),false,false,true,10,3.2)%></td>
								<td width="10%">Calificaci&oacute;n</td>
								<td width="20%"><%=fb.textBox("calificacion",eval.getCalificacion(),false,false,false,20,20)%></td>
								<td width="10%">Aceptaci&oacute;n</td>
								<td width="10%"><%=fb.checkbox("aceptoEmpleado","S",(eval.getAceptoEmpleado().equalsIgnoreCase("S")),false)%></td>
							</tr>
						    <tr class="TextRow01">
								<td colspan="2">Comentarios del Empleado</td>								
								<td colspan="6"><%=fb.textBox("comentarioEmpleado",eval.getComentarioEmpleado(),false,false,false,101,2000)%></td>	
							</tr>
							<tr class="TextRow01">
								<td colspan="2">Observaciones del Evaluador</td>								
								<td colspan="6"><%=fb.textBox("observacionesEvaluador",eval.getObservacionesEvaluador(),false,false,false,101,2000)%></td>	
							</tr>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
            <%=fb.radio("saveOption","O",true,false,false)%>Mantener Abierto 
            <%=fb.radio("saveOption","C")%>Cerrar 
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB2 DIV END HERE-->
</div>
<!-- MAIN DIV END HERE -->
</div>

<script type="text/javascript">
<%
if (mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Evaluación'),0,'100%','');
<%
}
else
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Evaluación','Materias a Mejorar','Limitaciones Encontradas','Resultado'),<%=tab%>,'100%','');
<%
}
%>
</script>

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
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	prov = request.getParameter("provincia");
	sigla = request.getParameter("sigla");
	tomo = request.getParameter("tomo");
	asiento = request.getParameter("asiento");
	id = request.getParameter("id"); 
	emp_id = request.getParameter("emp_id");
	
		 EvalEmpleado evalEmp = new EvalEmpleado();
		
		 evalEmp.setCodigo(id);
		 evalEmp.setCompania((String) session.getAttribute("_companyId"));
		 evalEmp.setProvincia(request.getParameter("provincia"));
		 evalEmp.setSigla(request.getParameter("sigla"));
		 evalEmp.setTomo(request.getParameter("tomo"));
		 evalEmp.setAsiento(request.getParameter("asiento"));
		 evalEmp.setEmpId(request.getParameter("emp_id"));
		 
	if(tab==0)
	{
		int keySize = Integer.parseInt(request.getParameter("factSize"));	   
	  mode = request.getParameter("mode");
	  factLastLineNo = Integer.parseInt(request.getParameter("factLastLineNo"));	
	  ArrayList list = new ArrayList();	  
		String ItemRemoved = "";
		for (int i=1; i<=keySize; i++)
	  {
	    FactoresEval fa = new FactoresEval();

	    fa.setFactor(request.getParameter("factor"+i));
			fa.setDescripcion(request.getParameter("descripcion"+i));
			fa.setValor(request.getParameter("valor"+i));
			fa.setValorMin(request.getParameter("valorMin"+i));
			fa.setValorMax(request.getParameter("valorMax"+i));
				 
	    key = request.getParameter("key"+i);

		if (request.getParameter("remove"+i) != null && request.getParameter("remove"+i).equalsIgnoreCase("X"))
		{ 		  
		  ItemRemoved = key;		 
		}
		else
		{
	      try{ 
		        iFact.put(key,fa);
		        list.add(fa);
		     }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
	    }
	  }	//for

	  if (!ItemRemoved.equals(""))
	  {
			 vFact.remove(((FactoresEval) iFact.get(ItemRemoved)).getFactor());
			 iFact.remove(ItemRemoved);
			 response.sendRedirect("../rhplanilla/evaluacion_empleado_config.jsp?tab=0&mode="+mode+"&factLastLineNo="+factLastLineNo+"&matLastLineNo="+matLastLineNo+"&limLastLineNo="+limLastLineNo+"&id="+id+"&prov="+prov+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento);
			 return;
	  }

		 
		 evalEmp.setProvinciaEval(request.getParameter("provinciaEval"));
		 evalEmp.setSiglaEval(request.getParameter("siglaEval"));
		 evalEmp.setTomoEval(request.getParameter("tomoEval"));
		 evalEmp.setAsientoEval(request.getParameter("asientoEval"));
		 evalEmp.setFechaEvaluacion(request.getParameter("fechaEvaluacion"));
		 evalEmp.setPeriodoEvdesde(request.getParameter("periodoEvdesde"));
		 evalEmp.setPeriodoEvhasta(request.getParameter("periodoEvhasta"));
		 evalEmp.setTipoEvaluacion(request.getParameter("tipoEvaluacion"));		 
		 evalEmp.setResponsabilidades(request.getParameter("responsabilidades"));
		 evalEmp.setAceptoEmpleado("N");	
		 evalEmp.setPuntajeTotal(request.getParameter("puntajeTotal"));
		 evalEmp.setUnidadAdm(request.getParameter("unidadAdm"));	 
		 				
		 evalEmp.setFactores(list);
		 
		 if (mode.equalsIgnoreCase("add"))
		 {	 
				EvalMgr.add(evalEmp);
				id = EvalMgr.getPkColValue("codigo");
		 }
		 else if (mode.equalsIgnoreCase("edit"))
		 {	  
		    evalEmp.setCodigo(id);	    
				EvalMgr.update(evalEmp);
		 }
	}
	else if(tab==1)
	{
		int keySize=Integer.parseInt(request.getParameter("matSize"));	   
	  matLastLineNo = Integer.parseInt(request.getParameter("matLastLineNo"));
	  String ItemRemoved = "";
	  for (int i=1; i<=keySize; i++)
	  {
		FactoresEval factMat = new FactoresEval();
		factMat.setCodigo(request.getParameter("codigo"+i));
		factMat.setSigla(request.getParameter("sigla"));
	  factMat.setTomo(request.getParameter("tomo"));
	  factMat.setAsiento(request.getParameter("asiento"));
		factMat.setCompania((String) session.getAttribute("_companyId"));
		factMat.setEvaluacion(id);
		factMat.setDescripcion(request.getParameter("descripcion"+i));
		
	  key = request.getParameter("key"+i);
		factMat.setKey(key);
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{ 		  
		  ItemRemoved = key;		 
		}
		else
		{
	      try{ 
		        iMat.put(key,factMat);
						evalEmp.addMaterias(factMat);
		     }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
	    }
	  }	
	
	  if (!ItemRemoved.equals(""))
	  {
	     iMat.remove(ItemRemoved);
	response.sendRedirect("../rhplanilla/evaluacion_empleado_config.jsp?change=1&tab=1&mode="+mode+"&factLastLineNo="+factLastLineNo+"&matLastLineNo="+matLastLineNo+"&limLastLineNo="+limLastLineNo+"&id="+id+"&prov="+prov+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&emp_id="+emp_id);
		 return;
	  }
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  {	
		  FactoresEval factMat = new FactoresEval();
			factMat.setCodigo("0");
			matLastLineNo++;
	    if (matLastLineNo < 10) key = "00" + matLastLineNo;
	    else if (matLastLineNo < 100) key = "0" + matLastLineNo;
	    else key = "" + matLastLineNo;
			factMat.setKey(key);
	
		try{ 
		     iMat.put(factMat.getKey(),factMat);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../rhplanilla/evaluacion_empleado_config.jsp?change=1&tab=1&mode="+mode+"&factLastLineNo="+factLastLineNo+"&matLastLineNo="+matLastLineNo+"&limLastLineNo="+limLastLineNo+"&id="+id+"&prov="+prov+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&emp_id="+emp_id);
		return;
	  }
	  if (baction.equalsIgnoreCase("Guardar"))
		{
	  		EvalMgr.addDetalle(evalEmp,1);
		}
	}
	else if(tab==2)
	{
			int keySize=Integer.parseInt(request.getParameter("limSize"));	   
			String ItemRemoved = "";
	    	   	  
	  for (int i=1; i<=keySize; i++)
	  {
	    FactoresEval facLim = new FactoresEval();

		facLim.setCodigo(request.getParameter("codigo"+i));
		facLim.setProvincia(prov);
		facLim.setSigla(sigla);
		facLim.setTomo(tomo);
		facLim.setAsiento(asiento);
		//facLim.setEmpId(emp_id);
		facLim.setCompania((String) session.getAttribute("_companyId"));
		facLim.setEvaluacion(id);
		facLim.setDescripcion(request.getParameter("descripcion"+i));
		facLim.setKey(request.getParameter("key"+i));

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		{ 		  
		  ItemRemoved = facLim.getKey();		 
		}
		else
		{
	      try{ 
		        iLim.put(facLim.getKey(),facLim);
						evalEmp.addMaterias(facLim);
		     }catch(Exception e){ System.err.println(e.getMessage()); }			    	       
	    }
	  }	
	
	  if (!ItemRemoved.equals(""))
	  {
	     iLim.remove(ItemRemoved);
		 response.sendRedirect("../rhplanilla/evaluacion_empleado_config.jsp?change=1&tab=2&mode="+mode+"&factLastLineNo="+factLastLineNo+"&matLastLineNo="+matLastLineNo+"&limLastLineNo="+limLastLineNo+"&id="+id+"&prov="+prov+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&emp_id="+emp_id);
		 return;
	  }
	  
	  if (request.getParameter("baction") != null && request.getParameter("baction").equals("+"))
	  {	
		 FactoresEval facLim = new FactoresEval();
				
		++limLastLineNo;
	    if (limLastLineNo < 10) key = "00" + limLastLineNo;
	    else if (limLastLineNo < 100) key = "0" + limLastLineNo;
	    else key = "" + limLastLineNo;
			facLim.setKey(key);
			facLim.setCodigo("0");

		try{ 
		     iLim.put(facLim.getKey(),facLim);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../rhplanilla/evaluacion_empleado_config.jsp?change=1&tab=2&mode="+mode+"&factLastLineNo="+factLastLineNo+"&matLastLineNo="+matLastLineNo+"&limLastLineNo="+limLastLineNo+"&id="+id+"&prov="+prov+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&emp_id="+emp_id);
		return;
	  }
	  
	  
	  if (baction.equalsIgnoreCase("Guardar"))
		{
	  		EvalMgr.addDetalle(evalEmp,2);
		}
	
	}
	else if(tab==3)
	{
	//updateResultado
	
	evalEmp.setCalificacion(request.getParameter("calificacion"));
	evalEmp.setComentarioEmpleado(request.getParameter("comentarioEmpleado"));
	evalEmp.setObservacionesEvaluador(request.getParameter("observacionesEvaluador"));
	evalEmp.setAceptoEmpleado((request.getParameter("aceptoEmpleado") == null)?"N":"S");
	EvalMgr.addDetalle(evalEmp,3);		
	
	}
	

	
	
	 
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (EvalMgr.getErrCode().equals("1"))
{
%>
	alert('<%=EvalMgr.getErrMsg()%>');
<%
	if (tab==0)
	{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/evaluacion_empleado_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/evaluacion_empleado_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/evaluacion_empleado_list.jsp';
<%
		}
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
} else throw new Exception(EvalMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&id=<%=id%>&prov=<%=prov%>&sigla=<%=sigla%>&tomo=<%=tomo%>&asiento=<%=asiento%>&emp_id=<%=emp_id%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>