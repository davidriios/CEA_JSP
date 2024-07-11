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
<jsp:useBean id="iMed" scope="session" class="java.util.Hashtable" />

<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alDiagIn = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoPaciente = new CommonDataObject();
CommonDataObject cdoDet = new CommonDataObject();


boolean viewMode = false;
String sql = "";
String mode = request.getParameter("mode");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String cds = request.getParameter("cds");
String desc = request.getParameter("desc");
String nextRecId = request.getParameter("nextRecId");
String expStatus = request.getParameter("exp_status")==null?"":request.getParameter("exp_status");
String noIndicacion = request.getParameter("no_indicacion")==null? "" : request.getParameter("no_indicacion");
String noDosis = request.getParameter("no_dosis")==null? "" : request.getParameter("no_dosis");
String noFrecuencia = request.getParameter("no_frecuencia")==null? "" : request.getParameter("no_frecuencia");
String noDuracion = request.getParameter("no_duracion")==null? "" : request.getParameter("no_duracion");
String from = request.getParameter("from") == null ? "": request.getParameter("from");
String mergedWithResCli = request.getParameter("merged_with_res_cli") == null ? "": request.getParameter("merged_with_res_cli");

if (mode == null) mode = "add";
if (cds == null) cds = "";
if (nextRecId==null) nextRecId = "";

if (mode.equalsIgnoreCase("view")) viewMode = true;
if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String tab = request.getParameter("tab");
String change = request.getParameter("change");
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String key = "";

int medLastLineNo = 0;

if (tab == null) tab = "0";
if (request.getParameter("medLastLineNo") != null) medLastLineNo = Integer.parseInt(request.getParameter("medLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(desc == null) desc = "";
if(change == null)
{
	iMed.clear(); 

	sql="select m.pac_id, m.admision, m.secuencia,m.medicamento, nvl(m.indicacion,'N/A') indicacion, m.dosis, m.frecuencia, m.duracion, m.no_receta ,nvl((select count(*) from tbl_sal_recetas a where a.pac_id = m.pac_id and a.admision = m.admision and a.id_recetas = m.no_receta and a.status = 'P'),0) as tot_imp, m.usuario_creacion as uc, to_char(m.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') as fc,to_char(m.fecha_modificacion,'dd/mm/yyyy hh12:mi:ss am') as fm, usuario_modificacion as um from tbl_sal_salida_medicamento m where  m.pac_id = "+pacId+" and m.admision = "+noAdmision+" order by m.no_receta";

	al = SQLMgr.getDataList(sql);
	medLastLineNo = al.size();
	for (int i=1; i<=al.size(); i++)
	{
		CommonDataObject icdo = (CommonDataObject) al.get(i-1);

		if (i < 10) key = "00" + i;
		else if (i < 100) key = "0" + i;
		else key = "" + i;

		icdo.addColValue("key",key);
		icdo.setAction("U");

		try
		{
			iMed.put(key, icdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}
	if (al.size() == 0)
	{
		CommonDataObject icdo = new CommonDataObject();
		icdo.addColValue("secuencia","0");
		
		if(noIndicacion.trim().equals("Y")) icdo.addColValue("indicacion","N/A");
		if(noDosis.trim().equals("Y")) icdo.addColValue("dosis","N/A");
		if(noFrecuencia.trim().equals("Y")) icdo.addColValue("frecuencia","N/A");
		if(noDuracion.trim().equals("Y")) icdo.addColValue("duracion","N/A");
		
		icdo.setAction("I");

		medLastLineNo++;
		if (medLastLineNo < 10) key = "00" + medLastLineNo;
		else if (medLastLineNo < 100) key = "0" + medLastLineNo;
		else key = "" + medLastLineNo;
		icdo.addColValue("key",key);
		try
		{
			iMed.put(key, icdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
	}			
}//change

if (expStatus.trim().equals("F")) viewMode = viewMode;
else viewMode = false;

if (mergedWithResCli.trim().equalsIgnoreCase("Y")) viewMode = true;
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param_bootstrap.jsp"%>
<%@ include file="../common/autocomplete_header.jsp"%>
<script>
var noNewHeight = true;
document.title = 'EXPEDIENTE - PLAN DE SALIDA - MEDICAMENTOS (RECETAS) '+document.title;

function doAction(){}

$(function(){
  $("#agregar").click(function(c){
	 var recIds = getRecId();
	 var maxRecId = recIds[recIds.length-1];
	 $("#nextRecId").val(maxRecId);
	 setBAction('form1',"+");
	 $("#form1").submit();
  });
});

function getRecId(){
  var totMed = parseInt("<%=iMed.size()%>",10);
  var recObj = [];
  for (i=1; i<=totMed; i++){
     if ($("#no_receta"+i).val())recObj.push($("#no_receta"+i).val());
	 if ( $("#no_receta"+i).val() && !isInteger($("#no_receta"+i).val()) ) {
		isValid = false; 
		$("#no_receta"+i).select();
		break;
	 }else if ( parseInt($("#no_receta"+i).val()) < 1){isValid = false; break;}
  }
  recObj = removeDups(recObj);
  return recObj;
}

function isAvalidNoRec(){
  var isValid = true;
  var recObj = [];
  var totMed = parseInt("<%=iMed.size()%>",10);
  for (i=1; i<=totMed; i++){
     if ($("#no_receta"+i).val())recObj.push($("#no_receta"+i).val());
	 if ( $("#no_receta"+i).val() && !isInteger($("#no_receta"+i).val()) ) {
		isValid = false; 
		$("#no_receta"+i).select();
		break;
	 }else if ( parseInt($("#no_receta"+i).val()) < 1){isValid = false; break;}
  }
  recObj = removeDups(recObj);
  if (recObj[recObj.length-1] > recObj.length){isValid=false;}
  return isValid;
}

function alreadyPrintedAll(){
   /*var t = parseInt("<%=iMed.size()%>");
   var rObj = [];
   var halt = false;
   var d = 0;
   for (r = 1; r<=t; r++){
	 if ( $("#action"+r).val() == "I"){
	   rObj.push( $("#no_receta"+r).val() );
	 }
   }
   rObj = removeDups(rObj);
   if (rObj.length > 0){
     d = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_recetas','pac_id=<%=pacId%> and admision=<%=noAdmision%> and id_recetas in('+rObj+') and status = \'P\' ','');
	 if (d > 0) {alert("Perdona, pero usted está tratando de insertar un medicamento en una receta ya impresa!"); halt=true;$("#no_receta"+r).select();}
	 else halt = false;
   }else{halt = false;}
   return halt;*/
   return false;
}

function alreadyPrinted(ind, dontSubmit){
  var noReceta = $("#no_receta"+ind).val();
  var action = $("#action"+ind).val();
  var d, proceed = true;
  if (!isInteger(noReceta)) {proceed = false; return false;}
  else{
	  //d = getDBData('<%=request.getContextPath()%>','count(*)','tbl_sal_recetas','pac_id=<%=pacId%> and admision=<%=noAdmision%> and id_recetas = '+noReceta+' and status = \'P\' ','') || 0;
	  d = 0;
	  	  
	  if (dontSubmit && d > 0) {
	    $("#no_receta"+ind).val("");
	    alert("La receta "+noReceta+" ya fue impreso!"); 
		proceed = false;
	  }
	  else {
		  if (d>0 && "I" != action){
			alert("Usted está tratando de eliminar un medicamento ya impreso en una receta!"); 
			proceed = false;
		  }else{
		    if(!dontSubmit) {
			 removeItem('form1',ind); proceed = true;
			 }
		  }
	  }
  }
  if (!dontSubmit && proceed===true) $("#form1").submit();
}

function printRecetas(){
   <%if(!viewMode){%>
   abrir_ventana("../expediente/exp_gen_recetas.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&desc=<%=desc%>&seccion=<%=seccion%>&from=<%=from%>");<%}%>
} 
</script>
</head>
<body class="body-form" onLoad="javascript:doAction()">
<div class="row">
<div class="table-responsive" data-pattern="priority-columns">

<div class="headerform">
    <table cellspacing="0" class="table pull-right table-striped table-custom-1">
        <tr>
            <td class="controls form-inline">
                <button type="button" name="imprimir_recetas" id="imprimir_recetas" class="btn btn-inverse btn-sm" onclick="javascript:printRecetas()"><i class="fa fa-print fa-lg"></i> Recetas</button>
            </td>
        </tr>
    </table>
</div>

 <table cellspacing="0" class="table table-small-font table-bordered table-striped">
     <%fb = new FormBean2("form1",request.getContextPath()+request.getServletPath(),FormBean2.POST);%>
     <%=fb.formStart(true)%>
     <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar' && document."+fb.getFormName()+".baction.value!='Siguiente')return true;");%>
     <%=fb.hidden("baction","")%>
     <%=fb.hidden("mode",mode)%>
     <%=fb.hidden("seccion",seccion)%>
     <%=fb.hidden("dob","")%>
     <%=fb.hidden("codPac","")%>
     <%=fb.hidden("pacId",pacId)%>
     <%=fb.hidden("noAdmision",noAdmision)%>
     <%=fb.hidden("tab","1")%>
     <%=fb.hidden("medLastLineNo",""+medLastLineNo)%>
     <%=fb.hidden("mSize",""+iMed.size())%>
     <%=fb.hidden("cds",""+cds)%>
     <%fb.appendJsValidation("if(isAvalidNoRec()==false){alert('Por favor verifique que el número de receta no exceda la cantidad de medicamentos y que sea un entero!');error++;}");%>
     <%fb.appendJsValidation("if(alreadyPrintedAll()==true){error++;}");%>
     <%=fb.hidden("desc",""+desc)%>
     <%=fb.hidden("nextRecId",nextRecId)%>
     <%=fb.hidden("exp_status",expStatus)%>
     <%=fb.hidden("no_indicacion",noIndicacion)%>
     <%=fb.hidden("no_dosis",noDosis)%>
     <%=fb.hidden("no_frecuencia",noFrecuencia)%>
     <%=fb.hidden("no_duracion",noDuracion)%>
     <%=fb.hidden("from",from)%>
     <%=fb.hidden("merged_with_res_cli",mergedWithResCli)%>

     <tr class="bg-headtabla2" >
        <td colspan="7">MEDICAMENTOS RECETADOS</td>
     </tr>
     <tr class="bg-headtabla" align="center">
        <td width="5%" class="Text10">NO.RECETA</td>
        <td width="30%" class="Text10">MEDICAMENTO</td>
        <td width="16%" class="Text10">INDICACION</td>
        <td width="15%" class="Text10">DOSIS</td>
        <td width="15%" class="Text10">FRECUENCIA</td>
        <td width="15%" class="Text10">DURACION</td>
        <td width="4%" rowspan="2"><%=fb.button("agregar","+",false,viewMode,null,null,"","Agregar Medicamento")%></td>
    </tr>
    <tr class="bg-headtabla" align="center">
        <td class="Text10">&nbsp;</td>
        <td class="Text10">Nombre del medic.</td>
        <td class="Text10">Para qu&eacute; sirve</td>
        <td class="Text10">Cu&aacute;nto debe tomar</td>
        <td class="Text10">Frecuencia</td>
        <td class="Text10">Por cu&aacute;nto tiempo</td>
    </tr>

    <%
    int totImp = 0;
    al.clear();
    al = CmnMgr.reverseRecords(iMed);

    for (int i = 1; i <= iMed.size(); i++){

    key = al.get(i-1).toString();
    cdo = (CommonDataObject) iMed.get(key);
    totImp = Integer.parseInt(cdo.getColValue("tot_imp")==null||cdo.getColValue("tot_imp").equals("")?"0":cdo.getColValue("tot_imp"));
    String noReceta = cdo.getColValue("no_receta")==null?"":cdo.getColValue("no_receta");
    %>
     <%=fb.hidden("remove"+i,"")%>
     <%=fb.hidden("key"+i,key)%>
     <%=fb.hidden("tot_imp"+i,cdo.getColValue("tot_imp"))%>
     <%=fb.hidden("secuencia"+i,cdo.getColValue("secuencia"))%>
     <%=fb.hidden("fc"+i,cdo.getColValue("fc"))%>
     <%=fb.hidden("uc"+i,cdo.getColValue("uc"))%>
     <%=fb.hidden("fm"+i,cdo.getColValue("fm"))%>
     <%=fb.hidden("um"+i,cdo.getColValue("um"))%>
     <%=fb.hidden("action"+i,cdo.getAction())%>

    <tr>
        <td><%=fb.intBox("no_receta"+i,noReceta.equals("")?nextRecId:noReceta,true,false,(viewMode||totImp>0),4,2,"form-control input-sm",null,"")%></td>
        <td><jsp:include page="../common/autocomplete.jsp" flush="true">
                <jsp:param name="fieldId" value="<%="medicamento"+i%>"/>
                <jsp:param name="fieldValue" value="<%=(cdo.getColValue("medicamento")==null?"":cdo.getColValue("medicamento"))%>"/>
                <jsp:param name="fieldIsRequired" value="y"/>
                <jsp:param name="fieldIsReadOnly" value="<%=(viewMode||totImp>0)%>"/>
                <jsp:param name="fieldClass" value="form-control input-sm"/>
                <jsp:param name="dObjId" value=""/>
                <jsp:param name="dObjRefer" value=""/>
                <jsp:param name="containerSize" value="150%"/>
                <jsp:param name="maxDisplay" value="20"/>
                <jsp:param name="dsQueryString" value="cds=127"/>
                <jsp:param name="dsType" value="drug"/>
                <jsp:param name="unmatchClear" value="y"/>
            </jsp:include>
        </td>
        <td align="center"><%=fb.textBox("indicacion"+i,cdo.getColValue("indicacion"),(noIndicacion.equals("") || noIndicacion.equals("N")),false,(viewMode||totImp>0),15,"form-control input-sm",null,"onBlur=alreadyPrinted("+i+",true)")%></td>
        <td><%=fb.textBox("dosis"+i,cdo.getColValue("dosis"),(noDosis.equals("") || noDosis.equals("N")),false,(viewMode||totImp>0),15,"form-control input-sm",null,null)%></td>
        <td><%=fb.textBox("frecuencia"+i,cdo.getColValue("frecuencia"),(noFrecuencia.equals("") || noFrecuencia.equals("N")),false,(viewMode||totImp>0),15,"form-control input-sm",null,null)%></td>
        <td><%=fb.textBox("duracion"+i,cdo.getColValue("duracion"),(noDuracion.equals("") || noDuracion.equals("N")),false,(viewMode||totImp>0),15,"form-control input-sm",null,null)%></td>
        <td align="center"><%=fb.button("rem"+i,"x",false,viewMode,null,null,"onClick=alreadyPrinted("+i+")","Eliminar")%></td>
    </tr>
    <%}%>

  <%fb.appendJsValidation("if(error>0)newHeight();");%>
  
  <tr>
    <td colspan="7">
     
     <div class="footerform" style="bottom:-11px !important">
        <table cellspacing="0" class="table pull-right table-striped" style="text-align: right !important; vertical-align:inherit;">
            <tr>
                <td>
                  <%if(!from.equalsIgnoreCase("salida_pop")){%>
                        <%=fb.submit("save","Guardar",true,viewMode,null,null,"")%>
                        <%}else{%>
                          <%=fb.submit("save","Siguiente",true,viewMode,null,null,"onClick=\"setBAction('"+fb.getFormName()+"',this.value); parent.openNextAccordionPanel('"+fb.getFormName()+"')\"")%>
                        <%}%>
                
                </td>
            </tr>
        </table>   
     </div>
     
     
    </td>
  </tr>
  
  <%=fb.formEnd(true)%>
</table>

</div>
</div>

</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");
	String baction = request.getParameter("baction");
	String itemRemoved = "";
	cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

	int size = 0;
	al.clear();
	if (request.getParameter("mSize") != null) size = Integer.parseInt(request.getParameter("mSize"));

	for (int i=1; i<=size; i++)
	{
		CommonDataObject cdo2 = new CommonDataObject();
		cdo2.setTableName("tbl_sal_salida_medicamento");
		//cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
		cdo2.addColValue("pac_id",request.getParameter("pacId"));
		cdo2.addColValue("admision",request.getParameter("noAdmision"));
		cdo2.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		cdo2.addColValue("fecha_modificacion",cDateTime);
		
		if (request.getParameter("uc"+i)==null || request.getParameter("uc"+i).equals("")){
		  cdo2.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
          cdo2.addColValue("fecha_creacion",cDateTime);
		}

		if (request.getParameter("secuencia"+i) == null || ( request.getParameter("secuencia"+i).trim().equals("0")||request.getParameter("secuencia"+i).trim().equals("")))
		{
			cdo2.setAutoIncCol("secuencia");
			cdo2.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
            cdo2.addColValue("fecha_creacion",cDateTime);
			
			if (request.getParameter("um"+i)==null || request.getParameter("um"+i).equals("")){
		      cdo2.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
              cdo2.addColValue("fecha_modificacion",cDateTime);
		    }
			
			cdo2.setAutoIncWhereClause("pac_id="+request.getParameter("pacId")+" and admision = "+request.getParameter("noAdmision"));
		}else {
		   cdo2.setWhereClause("pac_id="+request.getParameter("pacId")+" and admision ="+request.getParameter("noAdmision")+" and secuencia="+request.getParameter("secuencia"+i));
		   cdo2.addColValue("secuencia",request.getParameter("secuencia"+i));
		}
		
		System.out.println("::::::::::::::::::::::::::"+request.getParameter("um"+i));

		cdo2.addColValue("medicamento",request.getParameter("medicamento"+i));		
		cdo2.addColValue("indicacion",request.getParameter("indicacion"+i));
		cdo2.addColValue("dosis",request.getParameter("dosis"+i));
		cdo2.addColValue("frecuencia",request.getParameter("frecuencia"+i));
		cdo2.addColValue("duracion",request.getParameter("duracion"+i));
		
		
		cdo2.addColValue("key",request.getParameter("key"+i));
		cdo2.setAction(request.getParameter("action"+i));
		cdo2.addColValue("tot_imp",request.getParameter("tot_imp"+i));
		cdo2.addColValue("no_receta",request.getParameter("no_receta"+i));

		key = request.getParameter("key"+i);
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals(""))
		itemRemoved = key;
		else
		{
		 try
			{
				al.add(cdo2);
				iMed.put(key,cdo2);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//else
	}//for
	if(!itemRemoved.equals(""))
	{
		iMed.remove(itemRemoved);
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&medLastLineNo="+medLastLineNo+"&cds="+cds+"&exp_status="+expStatus+"&no_indicacion="+noIndicacion+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion+"&from="+from+"&merged_with_res_cli="+mergedWithResCli);
		return;
	}
	if(baction.equals("+"))
	{
		CommonDataObject cdo2 = new CommonDataObject();

		cdo2.addColValue("secuencia","0");
		cdo2.addColValue("tot_imp","0");
		cdo2.setAction("I");
		
		if(noIndicacion.trim().equals("Y")) cdo2.addColValue("indicacion","N/A");
		if(noDosis.trim().equals("Y")) cdo2.addColValue("dosis","N/A");
		if(noFrecuencia.trim().equals("Y")) cdo2.addColValue("frecuencia","N/A");
		if(noDuracion.trim().equals("Y")) cdo2.addColValue("duracion","N/A");

		medLastLineNo++;
		if (medLastLineNo < 10) key = "00" +medLastLineNo;
		else if (medLastLineNo < 100) key = "0" +medLastLineNo;
		else key = "" +medLastLineNo;
		cdo2.addColValue("key",key);

		try
		{
			iMed.put(key,cdo2);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=1&mode="+mode+"&pacId="+request.getParameter("pacId")+"&seccion="+request.getParameter("seccion")+"&noAdmision="+request.getParameter("noAdmision")+"&medLastLineNo="+medLastLineNo+"&cds="+cds+"&nextRecId="+request.getParameter("nextRecId")+"&exp_status="+expStatus+"&no_indicacion="+noIndicacion+"&no_dosis="+noDosis+"&no_frecuencia="+noFrecuencia+"&no_duracion"+noDuracion+"&from="+from+"&merged_with_res_cli="+mergedWithResCli);
		return;
	}
	
	if (baction.equalsIgnoreCase("Guardar") || baction.equalsIgnoreCase("Siguiente"))
	{
		if (al.size() == 0)
		{
			CommonDataObject cdo3 = new CommonDataObject();

			cdo3.setTableName("tbl_sal_salida_medicamento");
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
<script type="text/javascript">
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
    <%if(from.equals("")){%>alert('<%=SQLMgr.getErrMsg()%>');<%}%>
	window.location = "../expediente3.0/exp_medicamentos_recetas.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&tab=1&cds=<%=cds%>&desc=<%=desc%>&seccion=<%=seccion%>&exp_status=<%=expStatus%>&no_indicacion=<%=noIndicacion%>&no_dosis=<%=noDosis%>&no_frecuencia=<%=noFrecuencia%>&no_duracion=<%=noDuracion%>&from=<%=from%>&merged_with_res_cli=<%=mergedWithResCli%>";
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