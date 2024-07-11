<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean2"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean2" />
<jsp:useBean id="iExpSecciones" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iValoresCriticos" scope="session" class="java.util.Hashtable" />
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

boolean viewMode = false;
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String modeSec = request.getParameter("modeSec");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");
String compania = (String) session.getAttribute("_companyId");

if (modeSec == null) modeSec = "add";
if (mode == null) mode = "add";
if (cds == null) cds = "";

if (modeSec.equalsIgnoreCase("view")) viewMode = true;
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String change = request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String fechaCreacion = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String key = "";
ArrayList alValCr = new ArrayList();
ArrayList alValCrAll = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if(desc==null){cdo = (CommonDataObject) iExpSecciones.get(seccion);desc = cdo.getColValue("descripcion");}
	
	sbSql.append("select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_sal_cds_val_criticos");
	if (!viewMode) sbSql.append(" where estado = 'A'"); /*and cds = "+cds+"*/
	sbSql.append(" order by 2");
	alValCr = sbb.getBeanList(ConMgr.getConnection(),sbSql.toString(),CommonDataObject.class);
	alValCrAll = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn, codigo as optTitleColumn from tbl_sal_cds_val_criticos order by 2",CommonDataObject.class);

	if(change == null){ 

		iValoresCriticos.clear();

		sbSql = new StringBuffer();
		sbSql.append("select v.secuencia, v.pac_id, v.admision, v.observacion, v.codigo_valor, v.valor, to_char(v.fecha_creacion,'dd/mm/yyyy hh12:mi am') fecha_creacion, medico_enterado, quien_recibe, quien_reporta, (select  primer_nombre|| ' '|| primer_apellido from tbl_adm_medico where codigo = medico_enterado and rownum = 1) medico_enterado_nombre, coalesce((select nombre_empleado from vw_pla_empleado where to_char(emp_id) = quien_recibe and rownum = 1),(select  primer_nombre|| ' '|| primer_apellido from tbl_adm_medico where codigo = quien_recibe and rownum = 1 ), (select upper(name) from tbl_sec_users where ref_code  = quien_recibe and rownum = 1)) quien_recibe_nombre, (select nombre_empleado from vw_pla_empleado where to_char(emp_id) = quien_reporta and rownum = 1) quien_reporta_nombre from tbl_sal_val_criticos v where v.pac_id = ");
		sbSql.append(pacId);
		sbSql.append(" and v.admision = ");
		sbSql.append(noAdmision);
		sbSql.append(" order by v.fecha_creacion");
		
		al = SQLMgr.getDataList(sbSql.toString());
		
		for (int i=0; i<al.size(); i++){
			cdo = (CommonDataObject) al.get(i);

			cdo.setKey(i);
			cdo.setAction("U");

			try
			{
				iValoresCriticos.put(cdo.getKey(),cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
		
		if (al.size() == 0){
			cdo = new CommonDataObject();
			cdo.addColValue("secuencia","0");

			cdo.setKey(iValoresCriticos.size()+1);
			cdo.setAction("I");
			cdo.addColValue("fecha_creacion",fechaCreacion);

			try
			{
				iValoresCriticos.put(cdo.getKey(),cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}//change
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<jsp:include page="../common/calendar_base.jsp" flush="true">
    <jsp:param name="bootstrap" value="bootstrap"/>
</jsp:include>
<script>
document.title = 'EXPEDIENTE - VALORES CRITICOS '+document.title;
var noNewHeight = true;
function doAction(){}

function print(){
	abrir_ventana1('../expediente3.0/print_valores_criticos.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&seccion=<%=seccion%>&desc=<%=desc%>');
}

function isAvalidNoRec(){
   var s = parseInt("<%=iValoresCriticos.size()%>",10);
   for (var i=0;i<s; i++){
      var fecha = $("#fecha"+i).val();
      var codValor = $("#codigo_valor"+i).val();
      var valor = $("#valor"+i).val();
      var action = $("#action"+i).val();
      var flag = true;
      
      if (!fecha && "I" == action) {
          alert("Por favor ingrese la fecha");
          flag = false;
          break;
      }
      
      if ("I" == action){
        var existed = parseInt(getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_val_criticos',"pac_id=<%=pacId%> and admision = <%=noAdmision%> and codigo_valor="+codValor+" and valor = '"+valor+"' and fecha_creacion = to_date('"+fecha+"','dd/mm/yyyy hh12:mi am')",''));
		 
        if (existed){
          alert("Esta tratando de registrar valores duplicados!");
		 
          $("#row"+i).each(function() {
            $.each(this.cells, function(){
                $(this).css({border:"red solid 2px"})
            });
          });
          flag = false;
          break;
        }
      }
   }
   return flag;
}

function medicoList(k){abrir_ventana1('../common/search_medico.jsp?fp=valores_criticos&index='+k);}
function empleadoList(k,opt){
    if (opt == 1)
        abrir_ventana1('../common/search_empleado.jsp?fp=valores_criticos&fg=quien_recibe&index='+k);
    else    
        abrir_ventana1('../common/search_empleado.jsp?fp=valores_criticos&fg=quien_reporta&index='+k);
}

$(function(){
  //$("label[id*='observacion']").hide();
});
</script>
<style>
table {
  width: 100%;
  border-collapse: collapse;
}

td, th {
  padding: .25em;
  border: 1px solid black;
}

tbody:nth-child(odd) {
  background: #CCC;
}
</style>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">
<%fb = new FormBean2("form2",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
<%=fb.formStart(true)%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("modeSec",modeSec)%>
<%=fb.hidden("seccion",seccion)%>
<%fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("dob","")%>
<%=fb.hidden("codPac","")%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("vcSize",""+iValoresCriticos.size())%>
<%=fb.hidden("cds",""+cds)%>
<%=fb.hidden("desc",""+desc)%>
<%fb.appendJsValidation("if(isAvalidNoRec()==false){error++;}");%>

<div class="headerform">
<table cellspacing="0" class="table pull-right table-striped table-custom-1">
    <tr>
        <td>            
            <button type="button" name="imprimirs" id="imprimirs" value="Imprimir" class="btn btn-primary btn-xs" onclick="javascript:print()"><i class="fa fa-print fa-lg"></i> Imprimir</button>
        </td>
    </tr>
</table>
</div>

<table class="table table-small-font table-bordered">  
     <thead>
     <tr><td colspan="5"></td></tr>
     <tr class="bg-headtabla2">
        <td width="15%" align="center"><cellbytelabel>Fecha</cellbytelabel></td>
        <td width="30%" align="center"><cellbytelabel>Prueba</cellbytelabel></td>
        <td width="10%" align="center"><cellbytelabel>Valor Cr&iacute;tico</cellbytelabel></td>
        <td width="40%"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
        <td width="5%" align="center">
        <%=fb.submit("agregar","+",false,viewMode,"btn btn-primary btn-xs",null,"onClick=\"javascript:__submitForm(this.form, this.value)\"","Agregar Valores Críticos")%>
        </td>
     </tr>
     </thead>
     
     <%
        String form = "'"+fb.getFormName()+"'";
        al.clear();
        al = CmnMgr.reverseRecords(iValoresCriticos);

        for (int i = 0; i <iValoresCriticos.size(); i++){
           key = al.get(i).toString();
           cdo = (CommonDataObject) iValoresCriticos.get(key);
     %>
           <%=fb.hidden("remove"+i,"")%>
           <%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
           <%=fb.hidden("action"+i,cdo.getAction())%>
           <%=fb.hidden("key"+i,cdo.getKey())%>

           <tbody>
           <tr align="center" id="row<%=i%>">
            <td class="controls form-inline">
                <jsp:include page="../common/calendar_bootstrap.jsp" flush="true">
                <jsp:param name="noOfDateTBox" value="1" />
                <jsp:param name="clearOption" value="true" />
                <jsp:param name="nameOfTBox1" value="<%="fecha"+i%>" />
                <jsp:param name="format" value="dd/mm/yyyy hh12:mi am" />
                <jsp:param name="hintText" value="01/01/2014 01:01 am" />
                <jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fecha_creacion")%>" />
                <jsp:param name="readonly" value="<%=(cdo.getAction().equals("U"))?"y":"n"%>"/>
                <jsp:param name="required" value="<%=(cdo.getAction().equals("U"))?"n":"y"%>"/>
              </jsp:include>
            </td>
            <td><%=fb.select("codigo_valor"+i,cdo.getAction().equals("U")?alValCrAll:alValCr,cdo.getColValue("codigo_valor"),true,false,cdo.getAction().equals("U"),0,"","","","","S")%></td>
            <td><%=fb.textBox("valor"+i,cdo.getColValue("valor"),true,false,cdo.getAction().equals("U"),10,500,"form-control input-sm",null,null)%></td>
            
            <td><%=fb.textarea("observacion"+i,cdo.getColValue("observacion"),false,false,cdo.getAction().equals("U"),25,1,0,"form-control input-sm",null,null)%></td>
            <td><%=fb.submit("rem"+i,"x",true,(cdo.getAction().equals("U")),"btn btn-danger btn-xs",null,"onClick=\"javascript:removeItem("+form+","+i+");__submitForm(this.form, this.value)\"","Eliminar")%></td>
        </tr>
        <tr>
          <td colspan="5" class="controls form-inline">
            <cellbytelabel>Recibe, Transcribe, lee y Confirma</cellbytelabel>:
            <%=fb.hidden("recibe_transcribe_confirma"+i,cdo.getColValue("quien_recibe", (cdo.getAction().equals("I")?UserDet.getRefCode():" ")))%>
             <%=fb.textBox("recibe_transcribe_confirma_nombre"+i,cdo.getColValue("quien_recibe_nombre", (cdo.getAction().equals("I")?UserDet.getName():" ")),cdo.getAction().equals("I"),false,true,0,"form-control input-sm","width:15%",null)%>
             <%=fb.button("btnMedico","...",true,cdo.getAction().equals("U"),"btn btn-primary btn-xs",null,"onClick=\"javascript:empleadoList("+i+", 1)\"","seleccionar medico")%>
             
            &nbsp;&nbsp;&nbsp;&nbsp;
            <cellbytelabel>Quien Reporta</cellbytelabel>:
            <%=fb.hidden("quien_reporta"+i,cdo.getColValue("quien_reporta"))%>
             <%=fb.textBox("quien_reporta_nombre"+i,cdo.getColValue("quien_reporta_nombre"),cdo.getAction().equals("I"),false,true,0,"form-control input-sm","width:15%",null)%>
             <%=fb.button("btnMedico","...",true,cdo.getAction().equals("U"),"btn btn-primary btn-xs",null,"onClick=\"javascript:empleadoList("+i+", 2)\"","seleccionar medico")%>

            &nbsp;&nbsp;&nbsp;&nbsp;
             <cellbytelabel>M&eacute;dico Enterado</cellbytelabel>:
             <%=fb.hidden("medico_enterado"+i,cdo.getColValue("medico_enterado"))%>
             <%=fb.textBox("medico_enterado_nombre"+i,cdo.getColValue("medico_enterado_nombre"),cdo.getAction().equals("I"),false,true,0,"form-control input-sm","width:15%",null)%>
             <%=fb.button("btnMedico","...",true,cdo.getAction().equals("U"),"btn btn-primary btn-xs",null,"onClick=\"javascript:medicoList("+i+")\"","seleccionar medico")%>
          </td>
        </tr>
        </tbody>
	<%}%>
    </table>
    
    <div class="footerform">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
                <td>
                <input type="hidden" name="saveOption" value="O">
                <%=fb.submit("save","Guardar",true,viewMode,"btn btn-inverse btn-sm",null,"")%>
                <button type="button" class="btn btn-inverse btn-sm" onclick="parent.doRedirect(0)" name="cancel" id="cancel"><i class="material-icons fa-printico">exit_to_app</i> <b>Cancelar</b></button></td>
            </tr>
        </table>   
    </div>

<%=fb.formEnd(true)%>
</div>
</div>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String itemRemoved = "";
 	
	int size = 0;
	al.clear();
	iValoresCriticos.clear();
	if (request.getParameter("vcSize") != null) size = Integer.parseInt(request.getParameter("vcSize"));

	for (int i=0; i<size; i++){
		CommonDataObject cdo2 = new CommonDataObject();
		cdo2.setTableName("tbl_sal_val_criticos");
		cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and codigo_valor="+request.getParameter("codigo_valor"+i)+" and secuencia="+request.getParameter("secuencia"+i));
		cdo2.addColValue("pac_id",request.getParameter("pacId"));
		cdo2.addColValue("admision",request.getParameter("noAdmision"));
		cdo2.addColValue("codigo_valor",request.getParameter("codigo_valor"+i));
		cdo2.addColValue("valor",request.getParameter("valor"+i));
		cdo2.addColValue("observacion",request.getParameter("observacion"+i));
		cdo2.addColValue("compania",compania);
        
		cdo2.addColValue("quien_recibe",request.getParameter("recibe_transcribe_confirma"+i));
		cdo2.addColValue("quien_reporta",request.getParameter("quien_reporta"+i));
		cdo2.addColValue("medico_enterado",request.getParameter("medico_enterado"+i));
		cdo2.addColValue("quien_recibe_nombre",request.getParameter("recibe_transcribe_confirma_nombre"+i));
		cdo2.addColValue("quien_reporta_nombre",request.getParameter("quien_reporta_nombre"+i));
		cdo2.addColValue("medico_enterado_nombre",request.getParameter("medico_enterado_nombre"+i));
		
		cdo2.addColValue("fecha_creacion",request.getParameter("fecha"+i));
		cdo2.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo2.addColValue("fecha_modificacion",cDateTime);
		
		if (request.getParameter("secuencia"+i)==null || ( request.getParameter("secuencia"+i).trim().equals("0")||request.getParameter("secuencia"+i).trim().equals("")))
		{
			cdo2.setAutoIncCol("secuencia");
			cdo2.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			//cdo2.setAutoIncWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));		
		}else cdo2.addColValue("secuencia",request.getParameter("secuencia"+i));
		
		cdo2.setAction(request.getParameter("action"+i));
		cdo2.setKey(i);

		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
			itemRemoved = cdo2.getKey();
			if (cdo2.getAction().equalsIgnoreCase("I")) cdo2.setAction("X");
			else cdo2.setAction("D");
		}

		if (!cdo2.getAction().equalsIgnoreCase("X")){
			try
			{
				iValoresCriticos.put(cdo2.getKey(),cdo2);
				al.add(cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
	}//for
	
	
	if(!itemRemoved.equals(""))
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&modeSec="+modeSec+"&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc);
			return;
	}
	
	if(baction.equals("+"))//Agregar
	{
		CommonDataObject cdo2 = new CommonDataObject();

		cdo2.addColValue("secuencia","0");
		cdo2.addColValue("fecha_creacion",fechaCreacion);
		cdo2.setAction("I");
		cdo2.setKey(iValoresCriticos.size()+1);
		
		System.out.println("::::::::::::::::::::::::::::::::::::::: fechaCreacion = "+fechaCreacion);

		try
		{
			iValoresCriticos.put(cdo2.getKey(),cdo2);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=2&modeSec="+modeSec+"&mode="+mode+"&seccion="+request.getParameter("seccion")+"&pacId="+request.getParameter("pacId")+"&noAdmision="+request.getParameter("noAdmision")+"&cds="+cds+"&desc="+desc);
		return;
	}
		
	if (baction.equalsIgnoreCase("Guardar"))
	{
		if (al.size() == 0)
		{
			CommonDataObject cdo3 = new CommonDataObject();

			cdo3.setTableName("tbl_sal_val_criticos");
			cdo3.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
			cdo3.setAction("I");
			al.add(cdo3);
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
	}
%>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&modeSec=edit&mode=<%=mode%>&pacId=<%=pacId%>&cds=<%=cds%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>';
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
