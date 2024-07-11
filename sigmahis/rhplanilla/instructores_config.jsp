<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="java.util.Vector"%>
<jsp:useBean id="ConMgr"       scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr"       scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet"      scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr"       scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr"       scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb"           scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htcurso"      scope="session" class="java.util.Hashtable"/>
<jsp:useBean id="hteducacion"  scope="session" class="java.util.Hashtable" />
<jsp:useBean id="htexp"        scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vctcurso"     scope="session" class="java.util.Vector" />
<jsp:useBean id="vcteducacion" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
800023	AGREGAR INSTRUCTORES
==================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"800023"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
CommonDataObject inst = new CommonDataObject();
ArrayList al= new ArrayList();	
String sql="";
String key="";
String mode=request.getParameter("mode");
String tab= request.getParameter("tab");
String change= request.getParameter("change");
String sig=request.getParameter("sig");
String tom=request.getParameter("tom");
String asi=request.getParameter("asi");
String prov= request.getParameter("prov");
String code= request.getParameter("code");
String otro= request.getParameter("otro");
int cursoLastLineNo = 0;
int expLastLineNo = 0;
int educaLastLineNo = 0;

if(tab == null)  tab = "0";
if(mode == null) mode ="add";

if(request.getParameter("cursoLastLineNo") != null)
cursoLastLineNo = Integer.parseInt(request.getParameter("cursoLastLineNo"));

if(request.getParameter("expLastLineNo") != null)
expLastLineNo = Integer.parseInt(request.getParameter("expLastLineNo"));

if(request.getParameter("educaLastLineNo") != null)
educaLastLineNo  = Integer.parseInt(request.getParameter("educaLastLineNo"));


if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{
	inst.addColValue("fecha",CmnMgr.getCurrentDate("dd/mm/yyyy"));
	htcurso.clear();
	hteducacion.clear();
	htexp.clear();
	vctcurso.clear();
	vcteducacion.clear();
	}
	else 
	{
	//if (prov == null) throw new Exception("El Instructor no es válido. Por favor intente nuevamente!");
//	if (sig  == null) throw new Exception("El Instructor no es válido. Por favor intente nuevamente!");
//	if (tom  == null) throw new Exception("El Instructor no es válido. Por favor intente nuevamente!");
//	if (asi  == null) throw new Exception("El Instructor no es válido. Por favor intente nuevamente!");
	sql="select compania,provincia||'-'||sigla||'-'||tomo||'-'||asiento as cedula, provincia, sigla, tomo, asiento, procedencia, nombre, apellido, to_char(fecha_nacimiento, 'dd/mm/yyyy') as fecha, direccion, institucion, profesion, telefono_oficina as telefono2, telefono_casa as telefono1 from tbl_pla_instructor where compania="+(String)session.getAttribute("_companyId")+" and provincia="+prov+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi;
	inst = SQLMgr.getData(sql);
	code="0";
	otro="0";
	if(change == null)
		
		{
		System.out.println("***********************************INSIDE WHEN CHANGE ="+change);
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.curso as curso, a.costo, a.evaluacion, a.observacion, b.codigo as ot, b.nombre as namecurso, b.area as codearea, c.provincia, c.sigla, c.tomo, c.asiento, c.nombre as nameInstructor, c.apellido from tbl_pla_curso_instructor a, tbl_pla_curso_di b, tbl_pla_instructor c where a.compania=b.compania and a.curso=b.codigo and a.compania=c.compania and c.provincia = a.provincia and a.sigla=c.sigla and a.tomo=c.tomo and a.asiento= c.asiento and  a.compania="+(String)session.getAttribute("_companyId")+" and a.provincia="+prov+" and a.sigla='"+sig+"' and a.tomo="+tom+" and a.asiento="+asi;
	
	al  = SQLMgr.getDataList(sql);
	
	htcurso.clear();
	hteducacion.clear();	
	vctcurso.clear();
	vcteducacion.clear();
	
	cursoLastLineNo = al.size();
	for (int i=1; i<=al.size(); i++)
	{
		CommonDataObject cdo = (CommonDataObject) al.get(i-1);

		if (i < 10) key = "00" + i;
		else if (i < 100) key = "0" + i;
		else key = "" + i;
		cdo.addColValue("key",key);

		try
		{
			htcurso.put(key, cdo);
			vctcurso.addElement(cdo.getColValue("curso"));
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	} //End For
	
	htexp.clear();
sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.codigo, a.lugar, a.descripcion, b.compania, b.provincia, b.sigla, b.tomo, b.asiento, b.nombre, b.apellido from tbl_pla_experiencia_inst a, tbl_pla_instructor b where a.provincia=b.provincia and a.sigla=b.sigla and a.tomo=b.tomo and a.asiento=b.asiento and a.compania= b.compania and a.compania="+(String) session.getAttribute("_companyId")+" and  a.provincia="+prov+" and a.sigla='"+sig+"' and a.tomo="+tom+" and a.asiento="+asi;
	al  = SQLMgr.getDataList(sql);
	
	expLastLineNo = al.size();
	for (int i=0; i<al.size(); i++)
	{
		expLastLineNo++;
		if (expLastLineNo < 10) key = "00" + expLastLineNo;
		else if (expLastLineNo < 100) key = "0" + expLastLineNo;
		else key = "" + expLastLineNo;
		htexp.put(key, al.get(i));
	} //End For
	
		sql="select a.compania, a.provincia, a.sigla, a.tomo, a.asiento, a.codigo, a.lugar, a.carrera, a.termino, a.nivel, a.tipo , b.codigo as cot, b.descripcion as educacioName, c.compania, c.provincia, c.sigla, c.tomo, c.asiento, c.nombre, c.apellido from tbl_pla_educacion_inst a, tbl_pla_tipo_educacion b, tbl_pla_instructor c where a.tipo= b.codigo and  a.provincia=c.provincia and a.sigla= c.sigla and a.tomo=c.tomo and a.asiento=c.asiento and a.compania=c.compania and a.compania="+(String)session.getAttribute("_companyId")+" and a.provincia="+prov+" and a.sigla='"+sig+"' and a.tomo="+tom+" and a.asiento="+asi;
		al  = SQLMgr.getDataList(sql); 
		
	educaLastLineNo = al.size();
	
			for (int i=1; i<=al.size(); i++)
			{
				CommonDataObject cdo = (CommonDataObject) al.get(i-1);

				if (i < 10) key = "00" + i;
				else if (i < 100) key = "0" + i;
				else key = "" + i;
				cdo.addColValue("key",key);

				try
				{
					hteducacion.put(key,cdo);
					vcteducacion.addElement(cdo.getColValue("tipo"));
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			} 
	
	
		}//End Change
	}
		
	
	

%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp"%>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title=" Instructor Agregar - "+document.title;

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

function Educacion()
{
abrir_ventana1('../rhplanilla/list_educacion.jsp?mode=<%=mode%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&cursoLastLineNo=<%=cursoLastLineNo%>&expLastLineNo=<%=expLastLineNo%>&educaLastLineNo=<%=educaLastLineNo%>');
}

function Cursoss()
{
abrir_ventana1('../rhplanilla/list_cursos.jsp?mode=<%=mode%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>&cursoLastLineNo=<%=cursoLastLineNo%>&expLastLineNo=<%=expLastLineNo%>&educaLastLineNo=<%=educaLastLineNo%>');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="INSTRUCTOR"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder">
	  <table align="center" width="100%" cellpadding="5" cellspacing="0">
        <tr>
          <td>
		  	<!-- MAIN DIV START HERE -->
            <div id="dhtmlgoodies_tabView1">
              <!-- Tab0 Div Start Here -->
              <div class="dhtmlgoodies_aTab">
                <table align="center" width="100%" cellpadding="0" cellspacing="1">
                  <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
                  <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                  <%=fb.formStart(true)%>
				  <%=fb.hidden("tab","0")%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("sig",sig)%> 
				  <%=fb.hidden("tom",tom)%> 
				  <%=fb.hidden("asi",asi)%> 
				  <%=fb.hidden("prov",prov)%> 
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("cursoSize",""+htcurso.size())%> 				  
				  <%=fb.hidden("experienciaSize",""+htexp.size())%>
				  <%=fb.hidden("educacionSize",""+hteducacion.size())%>
				   <%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				  <%=fb.hidden("expLastLineNo",""+expLastLineNo)%> 
				  <%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%>
				  <%=fb.hidden("otro",otro)%>
				  <%=fb.hidden("code",code)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">					
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Generales de Instructor</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel0">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01">
                          <td>&nbsp;C&eacute;dula</td>
                          <td colspan="2"><%=fb.intBox("provincia",inst.getColValue("provincia"),true,mode.equals("edit"),false,1,2)%> 
						  <%=fb.textBox("sigla",inst.getColValue("sigla"),true,mode.equals("edit"),false,1,2)%> 
						  <%=fb.intBox("tomo",inst.getColValue("tomo"),true,mode.equals("edit"),false,3,4)%> 
						  <%=fb.intBox("asiento",inst.getColValue("asiento"),true,mode.equals("edit"),false,3,5)%> </td>
                        </tr>
                        <tr class="TextRow01">
                          <td width="17%">&nbsp;Nombre</td>
                          <td width="83%"><%=fb.textBox("nombre",inst.getColValue("nombre"),true,false,false,50,30)%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Apellido</td>
                          <td><%=fb.textBox("apellido",inst.getColValue("apellido"),true,false,false,50,30)%></td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(01)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Direcci&oacute;n</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus01" style="display:none">+</label><label id="minus01">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel01">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01">
                          <td width="18%">&nbsp;Procedencia</td>
                          <td width="37%"><%=fb.select("procedencia","E=Externo,I=Interno",inst.getColValue("procedencia"))%>
                          <td width="20%">&nbsp;Fecha de Nacimineto</td>
                          <td width="25%"><jsp:include page="../common/calendar.jsp" flush="true">
							<jsp:param name="noOfDateTBox" value="1" />
							<jsp:param name="nameOfTBox1" value="fecha" />
							<jsp:param name="valueOfTBox1" value="<%=inst.getColValue("fecha")%>" />
							</jsp:include>
						  </td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Tel&eacute;fono Residencial</td>
                          <td><%=fb.textBox("telefono1",inst.getColValue("telefono1"),false,false,false,15,11)%></td>
                          <td>&nbsp;Tel&eacute;fono Oficina
                          <td><%=fb.textBox("telefono2",inst.getColValue("telefono2"),false,false,false,15,11)%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Direcci&oacute;n</td>
                          <td colspan="3"><%=fb.textBox("direccion",inst.getColValue("direccion"),true,false,false,50,100)%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Instituci&oacute;n</td>
                          <td colspan="3"><%=fb.textBox("institucion",inst.getColValue("institucion"),true,false,false,50,60)%></td>
                        </tr>
                        <tr class="TextRow01">
                          <td>&nbsp;Profesi&oacute;n</td>
                          <td colspan="3"><%=fb.textarea("profesion",inst.getColValue("profesion"),true,false,false,38,2)%></td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false)%> 
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
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
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("tab","1")%> 
				  <%=fb.hidden("mode",mode)%> 
				   <%=fb.hidden("prov",prov)%> 
				  <%=fb.hidden("sig",sig)%> 
				  <%=fb.hidden("tom",tom)%> 
				  <%=fb.hidden("asi",asi)%> 				
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("cursoSize",""+htcurso.size())%> 
				  <%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				  <%=fb.hidden("experienciaSize",""+htexp.size())%>
				  <%=fb.hidden("educacionSize",""+hteducacion.size())%> 
				  <%=fb.hidden("expLastLineNo",""+expLastLineNo)%> 
				  <%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%>
				  <%=fb.hidden("otro",otro)%>
				  <%=fb.hidden("code",code)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Instructores</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel1">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01">
                          <td width="15%">&nbsp;C&eacute;dula</td>
                          <td width="15%">&nbsp;<%=inst.getColValue("cedula")%></td>
                          <td width="15%" align="right">Nombre</td>
                          <td width="55%">&nbsp;<%=inst.getColValue("apellido")%>,&nbsp;<%=inst.getColValue("nombre")%></td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Cursos a Dictar</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel10">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextHeader" align="center">
                          <td width="5%">Curso</td>
                          <td width="18%">Descripci&oacute;n</td>
                          <td width="17%">&Aacute;rea</td>
                          <td width="8%">Costo</td>
                          <td width="25%">Evaluaci&oacute;n</td>
                          <td width="23%">Observaci&oacute;n</td>
                          <td width="4%"><%=fb.button("agregar","+",true,false,null,null,"onClick=\"javascript:Cursoss()\"","Agregar Cursos")%></td>
                        </tr>
                        <%
			System.out.println("******************************FORM1 htcurso.size ="+htcurso.size());			
			al = CmnMgr.reverseRecords(htcurso);				
			for (int i=1; i<=htcurso.size(); i++)
			{
			key = al.get(i - 1).toString();									  
			CommonDataObject cdo = (CommonDataObject) htcurso.get(key);
			%>
			<%System.out.println("******************************FORM1 CYCLE WHEN i ="+i+" AND KEY = "+cdo.getColValue("key"));%>
                        <%=fb.hidden("key"+i,cdo.getColValue("key"))%> 
						<%=fb.hidden("curso"+i,cdo.getColValue("curso"))%> 
						<%=fb.hidden("namecurso"+i,cdo.getColValue("namecurso"))%> 
						<%=fb.hidden("codearea"+i,cdo.getColValue("codearea"))%> 
						<%=fb.hidden("remove"+i,"")%>
                        <tr class="TextRow01">
                          <td align="center"><%=cdo.getColValue("curso")%></td>
                          <td>&nbsp;<%=cdo.getColValue("namecurso")%></td>
                          <td>&nbsp;<%=cdo.getColValue("codearea")%></td>
                          <td align="center"><%=fb.decBox("costo"+i,cdo.getColValue("costo"),false,false,false,8,11,"Text10",null,null)%></td>
                          <td><%=fb.textBox("evaluacion"+i,cdo.getColValue("evaluacion"),false,false,false,36,30,"Text10",null,null)%></td>
                          <td align="center"><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,false,20,2)%></td>
                          <td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Curso")%></td>
                        </tr>
                        <%
			}
			%>
                      </table></td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar:
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
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
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("tab","2")%> 
				  <%=fb.hidden("mode",mode)%> 
				  <%=fb.hidden("sig",sig)%> 
				  <%=fb.hidden("tom",tom)%> 
				  <%=fb.hidden("asi",asi)%> 
				  <%=fb.hidden("prov",prov)%> 
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("cursoSize",""+htcurso.size())%> 
				  <%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				  <%=fb.hidden("experienciaSize",""+htexp.size())%>
				  <%=fb.hidden("educacionSize",""+hteducacion.size())%> 
				  <%=fb.hidden("expLastLineNo",""+expLastLineNo)%> 
				  <%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%>
				  <%=fb.hidden("keySize",""+htexp.size())%>
				  <%=fb.hidden("code",code)%>
				  <%=fb.hidden("otro",otro)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(2)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Instructores</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus2" style="display:none">+</label><label id="minus2">-</label> </font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel2">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01">
                          <td width="15%">&nbsp;C&eacute;dula</td>
                          <td width="15%">&nbsp;<%=inst.getColValue("cedula")%></td>
                          <td width="15%" align="right">Nombre</td>
                          <td width="55%">&nbsp;<%=inst.getColValue("apellido")%>,&nbsp;<%=inst.getColValue("nombre")%></td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer"><table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Experiencia</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus20" style="display:none">+</label><label id="minus20">-</label></font>]&nbsp;</td>
                        </tr>
                      </table></td>
                  </tr>
                  <tr id="panel20">
                    <td><table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextHeader" align="center">
                          <td width="10%">C&oacute;digo</td>
                          <td width="40%">Lugar</td>
                          <td width="45%">Descripci&oacute;n</td>
                          <td width="5%" align="center"><%=fb.submit("btnagrega","Agregar",false,false)%></td>		

                        </tr>
                        <%if(htexp.size()>0)
						al=CmnMgr.reverseRecords(htexp);
						for(int a=0;a<al.size();a++)
						{ 					
						key = al.get(a).toString();
						CommonDataObject cdos= (CommonDataObject) htexp.get(key);		
						%>
                       	<%=fb.hidden("key"+a,key)%>
                        <tr class="TextRow01">
                          <td align="center">&nbsp;<%=fb.intBox("code"+a,cdos.getColValue("codigo"),false,false,true,2,2,"Text10",null,null)%></td>
                          <td><%=fb.textBox("lugar"+a,cdos.getColValue("lugar"),false,false,false,60,60,"Text10",null,null)%></td>
                          <td><%=fb.textBox("descripcion"+a,cdos.getColValue("descripcion"),false,false,false,65,100,"Text10",null,null)%></td>
                          <td align="center"><%=fb.submit("remover"+a,"Eliminar",false,false)%></td>
                        </tr>
                        <%
			}
			%>
                      </table></td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false)%>	<!--Guardar	-->	
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
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
                  <%=fb.formStart(true)%> 
				  <%=fb.hidden("tab","3")%> 
				  <%=fb.hidden("mode",mode)%>
				  <%=fb.hidden("sig",sig)%> 
				  <%=fb.hidden("tom",tom)%> 
				  <%=fb.hidden("asi",asi)%> 
				  <%=fb.hidden("prov",prov)%>
				  <%=fb.hidden("baction","")%> 
				  <%=fb.hidden("cursoSize",""+htcurso.size())%> 
				  <%=fb.hidden("cursoLastLineNo",""+cursoLastLineNo)%> 
				  <%=fb.hidden("experienciaSize",""+htexp.size())%>
				  <%=fb.hidden("educacionSize",""+hteducacion.size())%> 
				  <%=fb.hidden("expLastLineNo",""+expLastLineNo)%> 
				  <%=fb.hidden("educaLastLineNo",""+educaLastLineNo)%>
				  <%=fb.hidden("otro",otro)%>
				  <%=fb.hidden("code",code)%>
                  <tr class="TextRow02">
                    <td>&nbsp;</td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(3)" style="text-decoration:none; cursor:pointer">
					  <table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Instructores</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus3" style="display:none">+</label><label id="minus3">-</label></font>]&nbsp;</td>
                        </tr>
                      </table>
					</td>
                  </tr>
                  <tr id="panel3">
                    <td>
					  <table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextRow01">
                          <td width="15%" align="right">C&eacute;dula</td>
                          <td width="15%">&nbsp;<%=inst.getColValue("cedula")%></td>
                          <td width="15%" align="right">Nombre</td>
                          <td width="55%">&nbsp;<%=inst.getColValue("apellido")%>,&nbsp;<%=inst.getColValue("nombre")%></td>
                        </tr>
                      </table>
					 </td>
                  </tr>
                  <tr>
                    <td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
					  <table width="100%" cellpadding="1" cellspacing="0">
                        <tr class="TextHeader">
                          <td width="95%">&nbsp;Datos de su Educaci&oacute;n</td>
                          <td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
                        </tr>
                      </table>
					 </td>
                  </tr>
                  <tr id="panel30">
                    <td>
					<table width="100%" cellpadding="1" cellspacing="1">
                        <tr class="TextHeader" align="center">
                          <td width="6%">C&oacute;digo</td>
                          <td width="8%">C&oacute;d. Educaci&oacute;n</td>
                          <td width="15%">Educaci&oacute;n</td>
                          <td width="32%">Centro Educativo</td>
                          <td width="23%">Carrera</td>
                          <td width="5%">Termino</td>
                          <td width="7%">Nivel</td>
                          <td width="4%">&nbsp;<%=fb.button("agregar","+",true,false,null,null,"onClick=\"javascript:Educacion()\"","Agregar Educación")%></td>
                        </tr>
                        <%
							al = CmnMgr.reverseRecords(hteducacion);				
							for (int i=1; i<=hteducacion.size(); i++)
							{
							key = al.get(i - 1).toString();									  
							CommonDataObject cdo = (CommonDataObject) hteducacion.get(key);
						%>
                        <%=fb.hidden("key"+i,cdo.getColValue("key"))%> 
						<%=fb.hidden("tipo"+i,cdo.getColValue("tipo"))%> 
						<%=fb.hidden("educacioName"+i,cdo.getColValue("educacioName"))%> 
						<%=fb.hidden("remove"+i,"")%>
                        <tr class="TextRow01">
                          <td align="center"><%=fb.intBox("otro"+i,cdo.getColValue("codigo"),false,false,true,2,2,"Text10",null,null)%>
						  <%//=fb.intBox("codigo"+i,cdo.getColValue("codigo"),false,false,true,3,2,"Text10",null,null)%></td>
                          <td align="center"><%=cdo.getColValue("tipo")%></td>
                          <td>&nbsp;<%=cdo.getColValue("educacioName")%></td>
                          <td><%=fb.textBox("lugar"+i,cdo.getColValue("lugar"),true,false,false,48,60,"Text10",null,null)%></td>
                          <td><%=fb.textBox("carrera"+i,cdo.getColValue("carrera"),true,false,false,33,60,"Text10",null,null)%></td>
                          <td align="center"><%=fb.checkbox("termino"+i,"S",(cdo.getColValue("termino") != null && cdo.getColValue("termino").trim().equalsIgnoreCase("S")),false)%></td>
                          <td align="center"><%=fb.intBox("nivel"+i,cdo.getColValue("nivel"),false,false,false,5,15,"Text10",null,null)%></td>
                          <td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar Educación")%> </td>
                        </tr>
                        <%
			}
			%>
                      </table>
					 </td>
                  </tr>
                  <tr class="TextRow02">
                    <td align="right"> Opciones de Guardar: 
					<%=fb.radio("saveOption","N")%>Crear Otro 
					<%=fb.radio("saveOption","O")%>Mantener Abierto 
					<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
					<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%> 
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%> </td>
                  </tr>
                  <%=fb.formEnd(true)%>
                  <!-- ================================   F O R M   E N D   H E R E   ================================ -->
                </table>
                <!-- TAB3 DIV END HERE-->
              </div>
              <!-- MAIN DIV END HERE -->
            </div>
<script type="text/javascript">
<%
if(mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Instructor'),0,'100%','');
<%
}
else
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Instructor','Cursos','Experiencia','Educación'),<%=tab%>,'100%','');
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
<jsp:include page="../common/footer.jsp" flush="true"></jsp:include>
</body>
</html>
<%
}//GET
else
{
String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction = request.getParameter("baction");

	if (tab.equals("0")) //INSTRUCTOR
	{
	inst = new CommonDataObject();
	inst.setTableName("tbl_pla_instructor");	
	inst.addColValue("procedencia",request.getParameter("procedencia"));
	inst.addColValue("nombre",request.getParameter("nombre"));
	inst.addColValue("apellido",request.getParameter("apellido"));
	inst.addColValue("fecha_nacimiento",request.getParameter("fecha"));
	inst.addColValue("direccion",request.getParameter("direccion"));
	inst.addColValue("institucion",request.getParameter("institucion"));
	inst.addColValue("profesion",request.getParameter("profesion"));
	if (request.getParameter("telefono2") != null)
	inst.addColValue("telefono_oficina",request.getParameter("telefono2"));
	if (request.getParameter("telefono1") != null)
	inst.addColValue("telefono_casa",request.getParameter("telefono1"));
	
	if (mode.equalsIgnoreCase("add"))
		{
		inst.addColValue("provincia", request.getParameter("provincia")); 
		inst.addColValue("sigla",request.getParameter("sigla"));
		inst.addColValue("tomo",request.getParameter("tomo"));
		inst.addColValue("asiento",request.getParameter("asiento"));
	    inst.addColValue("compania",(String) session.getAttribute("_companyId"));
		SQLMgr.insert(inst);
		
		prov = request.getParameter("provincia");
		sig  = request.getParameter("sigla"); 
		tom  = request.getParameter("tomo"); 
		asi  = request.getParameter("asiento");
		
		}
	else if (mode.equalsIgnoreCase("edit"))
		{
			 inst.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+prov+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi);
			 
			SQLMgr.update(inst);
		}
	
	}//End Tab0
	
	else if (tab.equals("1")) // Tab1 Cursos
	{
	int size = 0;
	if (request.getParameter("cursoSize") != null) 
	size = Integer.parseInt(request.getParameter("cursoSize"));
	
	String itemRemoved = "";

	al.clear();
	
	for (int i=1; i<=size; i++)
		{
		System.out.println("*************************SIZE = "+size);
		CommonDataObject cdo = new CommonDataObject();
		
		cdo.setTableName("tbl_pla_curso_instructor");
		cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+prov+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi);
		cdo.addColValue("provincia",prov);
		cdo.addColValue("sigla",sig);
		cdo.addColValue("tomo",tom);	
		cdo.addColValue("asiento",asi);		
		cdo.addColValue("namecurso",request.getParameter("namecurso"+i));
		cdo.addColValue("codearea",request.getParameter("codearea"+i));
		cdo.addColValue("curso",request.getParameter("curso"+i));
		cdo.addColValue("costo",request.getParameter("costo"+i));
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));		
		cdo.addColValue("evaluacion",request.getParameter("evaluacion"+i));
		cdo.addColValue("observacion",request.getParameter("observacion"+i));
		cdo.addColValue("key",request.getParameter("key"+i));
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
				itemRemoved = cdo.getColValue("key");  
			else 
			{
				try
				{  System.out.println("************************ ADDIN cdo to HashTable AND KEY VALUE = "+cdo.getColValue("key"));
					htcurso.put(cdo.getColValue("key"),cdo); 
					al.add(cdo); 
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
		}//End For
		
		if (!itemRemoved.equals(""))
		{
		System.out.println("***************************************INSIDE  REMOVE VALUE = "+itemRemoved); 
			vctcurso.remove(((CommonDataObject) htcurso.get(itemRemoved)).getColValue("curso"));
    	htcurso.remove(itemRemoved);
        System.out.println("***************************************AFTER itemRemoved"); 
	    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&cursoLastLineNo="+cursoLastLineNo+"&expLastLineNo="+expLastLineNo+"&educaLastLineNo="+educaLastLineNo);
    	return;
		}
		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("tbl_pla_curso_instructor");
			cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+prov+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi);

			al.add(cdo); 
		}
		
		SQLMgr.insertList(al);
		
	}//End Tab1
	
	else if (tab.equals("2")) //Experiencia
	{
		ArrayList list= new ArrayList();
		int keySize=Integer.parseInt(request.getParameter("keySize"));
		String itemRemoved = "";
		//al.clear();
		for (int i=0; i<keySize; i++)
		//for (int i=1; i<=size; i++)
		{
		CommonDataObject cdo = new CommonDataObject();
		cdo.setTableName("tbl_pla_experiencia_inst");
		cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+prov+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi);		
		cdo.addColValue("provincia",prov);
		cdo.addColValue("sigla",sig);
		cdo.addColValue("tomo",tom);
		cdo.addColValue("asiento",asi);
		cdo.addColValue("lugar",request.getParameter("lugar"+i));
		cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.addColValue("codigo",request.getParameter("code"+i));
		cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+request.getParameter("prov")+" and sigla='"+request.getParameter("sig")+"' and tomo="+request.getParameter("tom")+" and asiento="+request.getParameter("asi"));
		cdo.setAutoIncCol("codigo");
		key=request.getParameter("key"+i); 
		System.out.println("+++++++++++++++ rembutton="+request.getParameter("remover"+i)+" key="+request.getParameter("key"+i));
			
			if(request.getParameter("remover"+i)== null)
			{
			list.add(cdo);
			htexp.put(key,cdo);
			}//End 
			else itemRemoved=key;
			
		}//End For
		
		 if(!itemRemoved.equals(""))
{

htexp.remove(key);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&cursoLastLineNo="+cursoLastLineNo+"&expLastLineNo="+expLastLineNo+"&educaLastLineNo="+educaLastLineNo);
//response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&expLastLineNo="+expLastLineNo);

return;
}//end if

System.out.println("++++++agregar+++++++++"+request.getParameter("btnagrega"));
if(request.getParameter("btnagrega")!=null)//Agregar
{
CommonDataObject cdo = new CommonDataObject();
cdo.addColValue("provincia","0");
cdo.addColValue("sigla","0");
cdo.addColValue("tomo","0");
cdo.addColValue("asiento","0");
cdo.addColValue("codigo","0");
expLastLineNo++;
if (expLastLineNo < 10) key = "00" + expLastLineNo;
else if (expLastLineNo < 100) key = "0" + expLastLineNo;
else key = "" + expLastLineNo;
htexp.put(key,cdo);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&mode="+mode+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&cursoLastLineNo="+cursoLastLineNo+"&expLastLineNo="+expLastLineNo+"&educaLastLineNo="+educaLastLineNo);
//response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&expLastLineNo="+expLastLineNo);

return;
}
SQLMgr.insertList(list);

}//End Tab2
	
else if (tab.equals("3")) //Educacion
	{
	int size = 0;
	if (request.getParameter("educacionSize") != null) 
	size = Integer.parseInt(request.getParameter("educacionSize"));
	String itemRemoved = "";

		al.clear();
		for (int i=1; i<=size; i++)
		{
		CommonDataObject cdo = new CommonDataObject();
		cdo.setTableName("TBL_PLA_EDUCACION_INST");
		cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+prov+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi);
		cdo.addColValue("provincia",prov);
		cdo.addColValue("sigla",sig);
		cdo.addColValue("tomo",tom);
		cdo.addColValue("asiento",asi);
		cdo.addColValue("lugar",request.getParameter("lugar"+i));
		cdo.addColValue("carrera",request.getParameter("carrera"+i));
		cdo.addColValue("termino",(request.getParameter("termino"+i)== null)?"N":"S");
		cdo.addColValue("nivel",request.getParameter("nivel"+i));
		cdo.addColValue("tipo",request.getParameter("tipo"+i));
		cdo.addColValue("educacioName",request.getParameter("educacioName"+i));
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		cdo.addColValue("key",request.getParameter("key"+i));
		cdo.addColValue("codigo",request.getParameter("otro"+i));
		cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+request.getParameter("prov")+" and sigla='"+request.getParameter("sig")+"' and tomo="+request.getParameter("tom")+" and asiento="+request.getParameter("asi"));
		cdo.setAutoIncCol("codigo");		
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
				itemRemoved = cdo.getColValue("key");  
			else 
			{
				try
				{
					hteducacion.put(cdo.getColValue("key"),cdo); 
					al.add(cdo); 
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}
			
		
		}//End For
		
		if (!itemRemoved.equals(""))
		{
		vcteducacion.remove(((CommonDataObject) hteducacion.get(itemRemoved)).getColValue("tipo"));
    	hteducacion.remove(itemRemoved);

  response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&prov="+prov+"&sig="+sig+"&tom="+tom+"&asi="+asi+"&cursoLastLineNo="+cursoLastLineNo+"&expLastLineNo="+expLastLineNo+"&educaLastLineNo="+educaLastLineNo);
    	return;
		}

		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();

			cdo.setTableName("TBL_PLA_EDUCACION_INST");  
			cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+prov+" and sigla='"+sig+"' and tomo="+tom+" and asiento="+asi); 

			al.add(cdo); 
		}

		SQLMgr.insertList(al);
		
	
	}//End Tab3
	

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
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/instructores_list.jsp"))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/instructores_list.jsp")%>';
<%
	}
	else
	{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/instructores_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&prov=<%=prov%>&sig=<%=sig%>&tom=<%=tom%>&asi=<%=asi%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
