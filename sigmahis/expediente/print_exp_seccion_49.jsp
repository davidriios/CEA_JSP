<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.PdfCreator"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.awt.Color" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="_comp" scope="session" class="issi.admin.Compania" />
<%@ include file="../common/pdf_header.jsp"%>
<%
/**
===============================================================================
===============================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alapgar, alEscala = new ArrayList();
ArrayList alCordon = new ArrayList();
CommonDataObject cdo, cdoPacData, cdoGetTot = new CommonDataObject();

boolean viewMode = false;
String sql = "", sqlTitle="", sqlGetTot="", sqlEscala="";
String mode = request.getParameter("mode");
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String desc = request.getParameter("desc");
float eTotal1 = 0.0f, eTotal5 = 0.0f;
String userName = UserDet.getUserName();
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
//if (seccion == null) throw new Exception("La Sección no es válida. Por favor intente nuevamente!");
if (pacId == null || noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");

String tab = request.getParameter("tab");
String cod_apgar= request.getParameter("cod_apgar");
String cDate="";
String cTime="";
String rouspan="";
int eTotal=0;
int aTotal=0;
boolean checkDefault = false;
if (tab == null) tab = "0";

cdoPacData = SQLMgr.getPacData(pacId, noAdmision);

//if (request.getMethod().equalsIgnoreCase("GET"))
//{
	
    String fecha = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
	String year = fecha.substring(6, 10);
	String month = fecha.substring(3, 5);
	String day = fecha.substring(0, 2);

	String servletPath = request.getServletPath();
	String fileName = servletPath.substring(servletPath.lastIndexOf("/") + 1, servletPath.indexOf("."))+"_"+year+"-"+month+"-"+day+"_"+UserDet.getUserId()+"_"+System.currentTimeMillis()+".pdf";

	if (month.equals("01")) month = "january";
	else if (month.equals("02")) month = "february";
	else if (month.equals("03")) month = "march";
	else if (month.equals("04")) month = "april";
	else if (month.equals("05")) month = "may";
	else if (month.equals("06")) month = "june";
	else if (month.equals("07")) month = "july";
	else if (month.equals("08")) month = "august";
	else if (month.equals("09")) month = "september";
	else if (month.equals("10")) month = "october";
	else if (month.equals("11")) month = "november";
	else month = "december";

	String companyImageDir = ResourceBundle.getBundle("path").getString("companyimages");
	String logoPath = companyImageDir+"/"+((_comp.getLogo() != null && !_comp.getLogo().trim().equals(""))?_comp.getLogo():"blank.gif");
	String statusPath = "";
	String directory = ResourceBundle.getBundle("path").getString("pdfdocs")+"/";
	String folderName = servletPath.substring(1, servletPath.indexOf("/",1));
	if (CmnMgr.createFolder(directory, folderName, year, month).equalsIgnoreCase("0")) throw new Exception("No se puede crear la carpeta! Intente nuevamente.");
	String redirectFile = "../pdfdocs/"+folderName+"/"+year+"/"+month+"/"+fileName;

	float width = 72 * 8.5f;//612
	float height = 72 * 11f;//792
	boolean isLandscape = false;
	float leftRightMargin = 18.0f;
	float topMargin = 13.5f;
	float bottomMargin = 9.0f;
	float headerFooterFont = 4f;
	StringBuffer sbFooter = new StringBuffer();
	boolean logoMark = true;
	boolean statusMark = false;
	String xtraCompanyInfo = "";
	String title = "EXPEDIENTE";
	String subtitle = desc;
	String xtraSubtitle = "";
	boolean displayPageNo = true;
	float pageNoFontSize = 0.0f;//between 7 and 10
	String pageNoLabel = null;//XXX=Current Page No., YYY=Total Pages
	String pageNoPoxX = null;//L=Left, R=Right
	String pageNoPosY = null;//T=Top, B=Bottom
	float cHeight = 11.0f;
    
    CommonDataObject paramCdo = SQLMgr.getData(" select nvl(get_sec_comp_param("+(String)session.getAttribute("_companyId")+", 'EXP_PAC_DATA_INCREASE_FONT_SIZE'),'N') is_landscape from dual ");
    if (paramCdo == null) {
    paramCdo = new CommonDataObject();
    paramCdo.addColValue("is_landscape","N");
    }
    if (paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("Y") || paramCdo.getColValue("is_landscape","N").equalsIgnoreCase("S")){
    cdoPacData.addColValue("is_landscape",""+isLandscape);}

	PdfCreator pc=null;
boolean isUnifiedExp=false;
pc = (PdfCreator) session.getAttribute("printExpedienteUnico");
if(pc==null){ pc = new PdfCreator(directory+folderName+"/"+year+"/"+month+"/"+fileName, width, height, isLandscape, sbFooter.toString(), leftRightMargin, topMargin, bottomMargin, headerFooterFont, logoMark, logoPath, statusMark, statusPath, displayPageNo, pageNoFontSize, pageNoLabel, pageNoPoxX, pageNoPosY);
isUnifiedExp=true;}


	Vector dHeader = new Vector();
			dHeader.addElement(".28");
			dHeader.addElement(".28");
			dHeader.addElement(".14");
			dHeader.addElement(".14");
			

	//table header
	pc.setNoColumnFixWidth(dHeader);
	
	pc.createTable();
		//first row
		// el Encabezado del PDF tiene estos 9 parametros definidos el inicio en JspUseBeans
	pdfHeader(pc, _comp, cdoPacData, xtraCompanyInfo, title, subtitle, xtraSubtitle, userName, fecha, dHeader.size());
	
	pc.setTableHeader(1);
	
	//------------------------------              DESCRIPCION TAB 1            --------------------- //
	sql = "select a.codigo as cod_apgar, a.descripcion as desc_apgar from tbl_sal_indicador_apgar a";
	al = SQLMgr.getDataList(sql);
	
	//1: FRECUENCIA CARDIACA 2: ESFUERZO RESPIRATORIO

	//----------------------------------        LISTADO DE CORDON UMBILICAL TAB2    ---------------------------------- //
	sql = "select a.descripcion, a.codigo as cordon, b.secuencia, nvl(b.respuesta,'N') as respuesta from tbl_sal_rn_cordon a, tbl_sal_evaluacion_cordon b where a.codigo=b.cod_cordon(+) and b.pac_id(+)="+pacId+" and b.secuencia(+)="+noAdmision+" order by a.descripcion";
	alCordon = SQLMgr.getDataList(sql);
	
	
//------------------------------             MANIOBRAS TAB 3               --------------------- //
	sql = "select fecha_nacimiento, codigo_paciente, secuencia, rn_apgar7, rn_calor as calor, rn_secado as secado, rn_asp_nasofar as aspNaso, rn_asp_gast as aspGast, rn_man_esp_rean as reAnimacion, rn_rean_card as cardiaca, rn_metabol as metabolica, rn_estim_ext as estimulacion, rn_estim_ext_otras as otras, rn_talla as talla, rn_peso as peso, rn_edad_gest_ex_fis as edad, rn_dif_resp as difResp, rn_cp_ictericia as piel, rn_cp_palidez as palidez, rn_cp_cianosis as cianosis, rn_malforma as malForm, rn_neuro as neuro, rn_abdomen as abdomen, rn_orino as orino, rn_exp_meco as meconio, rn_cardio as cardio, pac_id, nvl(to_char(dn_fecha_nacimiento,'dd/mm/yyyy'),' ') as dnFechaNac, nvl(to_char(dn_hora_nacimiento,'hh12:mi:ss am'),' ') as dnHoraNac, nvl(dn_sexo,' ') as dnSexo  from tbl_sal_serv_neonatologia where pac_id="+pacId+" and secuencia="+noAdmision;
	cdo = SQLMgr.getData(sql);

	pc.setFont(7,0,Color.WHITE);
    pc.addCols("PUNTUACION APGAR",0,dHeader.size(), Color.gray);
	
    pc.setFont(7,0);
	pc.addBorderCols("Descripción",1,1);
	pc.addBorderCols("Escala",1,1);	
	pc.addBorderCols("Minuto 1",1,1);
	pc.addBorderCols("Minuto 5",1,1);
	
	String apgar = "";
	String minuto1 = "";
	String minuto5 = "";
	
	CommonDataObject cdoT = new CommonDataObject();
	
	int ln = -1;
	for (int i=0; i<al.size(); i++)
	{
		CommonDataObject cdoS = (CommonDataObject) al.get(i);
		
       //--------------------------------      ESCALA TAB 1    ----------------------------------------//
		sql = "select cod_apgar, codigo, descripcion, valor from tbl_sal_ptje_x_ind_apgar where cod_apgar="+cdoS.getColValue("cod_apgar");
		alEscala = SQLMgr.getDataList(sql);
		
		pc.addBorderCols(cdoS.getColValue("desc_apgar"),0,dHeader.size(),0.5f,0.0f,0.0f,0.0f); //DESCRIPCION
		
		for(int e=0; e<alEscala.size();e++){
			
			pc.addCols("",0,1);
			
			CommonDataObject cdoE = (CommonDataObject)alEscala.get(e);
			
			
				//------------------------     GETTING THE RADIOBUTTONS VALUE    -----------------------------//
				sql = "select secuencia, cod_apgar,minuto1, minuto5, pac_id from tbl_sal_apgar_neonato where cod_apgar="+cdoE.getColValue("cod_apgar") +" and pac_id="+pacId +" order by cod_apgar";
			 cdoT = SQLMgr.getData(sql);
			 
			 if ( cdoT == null ) cdoT = new  CommonDataObject();
			 
			if(cdoS.getColValue("cod_apgar").equals(cdoE.getColValue("cod_apgar"))){
				
		   		    pc.addCols(cdoE.getColValue("descripcion")+" ["+cdoE.getColValue("valor")+"]",0,1); //ESCALA
		   			
		
			} //end if
			
			if(!apgar.equals(cdoE.getColValue("cod_apgar"))){
			  pc.addCols(cdoT.getColValue("minuto1"),1,1);
			}else{
			  pc.addCols("",1,1);	
			}
			if(!apgar.equals(cdoE.getColValue("cod_apgar"))){
			  pc.addCols(cdoT.getColValue("minuto5"),1,1);
			}else{
			  pc.addCols("",1,1);
			}
			
			apgar =   cdoE.getColValue("cod_apgar");
			
		
		} // end for e
		//pc.addCols("",1,1);
				
	}//End For
	
	if ( cdo == null ) cdo = new CommonDataObject();
	
	
	//-------------------------- GETTING THE TOTAL -------------------------------//
	sqlGetTot = "select sum(minuto1) as totmin1, sum(minuto5) as totmin5 from tbl_sal_apgar_neonato where pac_id = "+pacId;
	cdoGetTot = SQLMgr.getData(sqlGetTot);
	
	pc.addCols("",1,dHeader.size(),20.2f);
	
	pc.setFont(7,1);
	pc.addCols("Si está deprimido al 5to minuto. Tiempo en que logra Apgar 7: ",1,1);
	pc.addCols(cdo.getColValue("rn_apgar7"),0,1);
	pc.addBorderCols(cdoGetTot.getColValue("totmin1")+" Pts",1,1,0.0f,0.5f,0.0f,0.0f); //MINUTO 1 TOTAL
	pc.addBorderCols(cdoGetTot.getColValue("totmin5")+" Pts",1,1,0.0f,0.5f,0.0f,0.0f); //MINUTO 5 TOTAL
//*********************************************** EN TAB 1 **************************************************//	
	
//*********************************************** TAB 2 **************************************************//
	pc.addCols("",1,dHeader.size(),25.2f);
	pc.setFont(7,1, Color.WHITE);
	pc.addCols("EVALUACION CORDON UMBILICAL",0,dHeader.size(), Color.gray);
	
	pc.setFont(7,0);
	pc.addBorderCols("Descripción",1,1);
	pc.addBorderCols("SI",1,1);
	pc.addBorderCols("NO",1,1);
    pc.addCols("",1,1);
	
	String marcadoS="", marcadoN="";

	for(int i=0; i<alCordon.size();i++)
	{
		CommonDataObject cdoS = (CommonDataObject) alCordon.get(i);

			pc.addBorderCols(cdoS.getColValue("descripcion"),0,1,0.5f,0.0f,0.0f,0.0f);
			
			
			if(cdoS.getColValue("respuesta").equals("S")){
				marcadoS = "x";
				marcadoN = "";
			}else{
				marcadoS = "";
				marcadoN = "x";
			}
		
			  pc.addBorderCols(marcadoS,1,1,0.5f,0.0f,0.0f,0.0f);
			  pc.addBorderCols(marcadoN,1,1,0.5f,0.0f,0.0f,0.0f);
	          pc.addCols("",1,1);

	}//End For
//***************************************** END TAB 2 **********************************************************//

//******************************************* TAB 3 *************************************************************// 

String calor = "", sexo="", secado="", aspNaso="", aspGastro="", reanim="", cardio="",metabol="", estimul="",otras="", difResp="",colPiel="", palidez="", cianosis="", malformaciones="", neurologico="",abdo="", orino="",xpulso="",cardiov=""  ;
		
		pc.addCols("",1,dHeader.size(),20.2f);
		pc.setFont(7,1,Color.white);
		pc.addBorderCols("GENERALES DEL RECIEN NACIDO",0,dHeader.size(), Color.gray);
		
		pc.setFont(7,1);
	    pc.addBorderCols("Fecha Nacimiento",1,1);
	    pc.addBorderCols("Hora Nacimiento",1,1);
	    pc.addBorderCols("Sexo",1,2);

		pc.addCols(cdo.getColValue("dnFechaNac"),0,1);
		pc.addCols(cdo.getColValue("dnHoraNac"),0,1);
		
		if(cdo.getColValue("dnSexo")!=null && cdo.getColValue("dnSexo").equals("F")){
			sexo = "Niña";
		}else{
			sexo = "Niño";
		}
		pc.addCols(sexo,1,2);
//************************************************* END GENERALES DEL RECIEN NACIDO *************************************//	
	
		pc.addCols("",1,dHeader.size(),15.2f);
		pc.setFont(7,1,Color.white);
		pc.addBorderCols("MANIOBRAS DE RUTINA",0,dHeader.size(), Color.gray);
		
		if(cdo.getColValue("calor")!=null && cdo.getColValue("calor").equals("S")){
			 calor= "Si";
		}else{
			 calor= "No";
		}
		
		if(cdo.getColValue("secado")!=null && cdo.getColValue("secado").equals("S")){
			secado = "Si";
		}else{
		   secado = "No";	
		}
		
		if(cdo.getColValue("aspNaso")!= null && cdo.getColValue("aspNaso").equals("S")){
			aspNaso = "Si";
		}else{
			aspNaso = "No";
		}
		
		if(cdo.getColValue("aspGast")!= null && cdo.getColValue("aspGast").equals("S")){
			aspGastro = "Si";
		}else{
			aspGastro = "No";
		}
		
		pc.setFont(7,0);
	    pc.addCols("Calor: "+calor,1,1);
		pc.addCols("Secado: "+secado,1,1);
		pc.addCols("Aspiración Nasofaringea: "+aspNaso,1,1);
		pc.addCols("Aspiración Gastrica: "+aspGastro,1,1);
//************************************************* END MANIOBRAS DE RUTINA *************************************//			
		
		pc.addCols("",1,dHeader.size(),20.2f);
		pc.setFont(7,1,Color.white);
		pc.addBorderCols("MANIOBRAS ESPECIALES DE REANIMACION",0,dHeader.size(), Color.gray);
		
		pc.setFont(7,0);
		
		if(cdo.getColValue("reanimacion")!= null && cdo.getColValue("reanimacion").equals("NH")){
			reanim = "No se hizo";
		}
		
		if(cdo.getColValue("reanimacion")!= null && cdo.getColValue("reanimacion").equals("MS")){
			reanim = "Máscara Simple";
		}
		
	    if(cdo.getColValue("reanimacion")!= null && cdo.getColValue("reanimacion").equals("MP")){
			reanim = "Máscara Presión Positiva";
		}
		
		if(cdo.getColValue("reanimacion")!= null && cdo.getColValue("reanimacion").equals("IN")){
			reanim = "Intubación";
		} // Reanimacion
		
	    if(	cdo.getColValue("cardiaca")!=null && cdo.getColValue("cardiaca").equals("NH")){
		   cardio = "No se hizo";
	    }
	
		if(	cdo.getColValue("cardiaca")!=null && cdo.getColValue("cardiaca").equals("ME")){
		   cardio = "Masaje Externo";
		}	
		
		if(	cdo.getColValue("cardiaca")!=null && cdo.getColValue("cardiaca").equals("DG")){
		  cardio = "Drogas";
		}
		
		if(	cdo.getColValue("cardiaca")!=null && cdo.getColValue("cardiaca").equals("DG")){
		  cardio = "Drogas";
	    } //cardio
	
		if(cdo.getColValue("metabolica")!=null && cdo.getColValue("metabolica").equals("NH")){
		  metabol = "No se hizo";
		}
		
	    if(cdo.getColValue("metabolica")!=null && cdo.getColValue("metabolica").equals("AL")){
		  metabol = "Alcalinizantes";
	    }
		
	   if(cdo.getColValue("metabolica")!=null && cdo.getColValue("metabolica").equals("OT")){
		  metabol = "Otros";
	   }  //metabol
	
	   if(cdo.getColValue("Estimulacion")!=null && cdo.getColValue("Estimulacion").equals("S")){
		  estimul = "Si";
	   }else{
		 estimul = "No";
	   }
	
	   if(cdo.getColValue("otras")!=null && cdo.getColValue("otras").equals("S")){
		 otras = "Si";
	   }else{
		 otras = "No";
	   }
	
	   if(cdo.getColValue("difResp")!=null && cdo.getColValue("difResp").equals("S")){
		  difResp = "Si";
	   }else{
		 difResp = "No";
	   }
	
    pc.addBorderCols("Reanimación: "+reanim+"                                     Cardiaca: "+cardio+ "                                     Metabolica: "+metabol+ "                                     Estimulación Externa: "+estimul+"                                     Otras: "+otras,0,dHeader.size());
 
	pc.addCols("",1,dHeader.size(),15.2f);
	
    pc.addBorderCols("Talla",1,1);
	pc.addBorderCols("Peso",1,1);
	pc.addBorderCols("Edad Gest. por Examen Físico",1,1);
	pc.addBorderCols("Dificultad Respiratoria",1,1);
    
	pc.addCols(cdo.getColValue("talla"),1,1);
	pc.addCols(cdo.getColValue("peso"),1,1);
	pc.addCols("Semanas: "+cdo.getColValue("edad"),1,1);
    pc.addCols(difResp,1,1);
	
	
	if(cdo.getColValue("piel")!=null && cdo.getColValue("piel").equals("S")){
		colPiel="Si"; 
	}else{
		colPiel="No"; 
	}
	
	if(cdo.getColValue("palidez")!=null && cdo.getColValue("palidez").equals("S")){
	   palidez="Si"; 
	}else{
		palidez="No";
	}
	
	if(cdo.getColValue("cianosis")!= null && cdo.getColValue("cianosis").equals("S")){
	   cianosis="Si";
	}else{
		cianosis="No";
	}
	
	if(cdo.getColValue("malform")!=null && cdo.getColValue("malform").equals("S")){
	   malformaciones="Si";
	}else{
	  malformaciones="No";
	}
	
	if(cdo.getColValue("neuro")!=null && cdo.getColValue("neuro").equals("N")){
	   neurologico="Normal";
	}
	if(cdo.getColValue("neuro")!=null && cdo.getColValue("neuro").equals("D")){
			neurologico="Deprimido";
	}
	else{
	   neurologico="Exaltado";
	}
	
	pc.addCols("",1,dHeader.size(),15.2f);
	pc.addBorderCols("Color de la Piel Ictericia: "+colPiel+"                                   Palidez: "+palidez+ "                                   Cianosis: "+cianosis+ "                                   Malformaciones: "+malformaciones+"                                   Neurologico: "+neurologico,0,dHeader.size());


   pc.addCols("",1,dHeader.size(),15.2f);

   pc.addBorderCols("Abdomen",1,1);
   pc.addBorderCols("Orinó",1,1);
   pc.addBorderCols("Expulso Meconio",1,1);
   pc.addBorderCols("Cardiovascular",1,1);

   if(cdo.getColValue("abdomen")!=null && cdo.getColValue("abdomen").equals("N")){
	   abdo="Normal";
   }else{
	   abdo="Anormal";
   }

   if(cdo.getColValue("mecomio")!=null && cdo.getColValue("mecomio").equals("S")){
	  xpulso= "Si"; 
   }else{
	  xpulso= "No"; 
   }
   
    if(cdo.getColValue("orino")!=null && cdo.getColValue("orino").equals("S")){
	  orino= "Si"; 
   }else{
	  orino= "No"; 
   }
   
   if(cdo.getColValue("cardio")!=null && cdo.getColValue("cardio").equals("S")){
	 cardiov= "Normal";  
   }else{
	 cardiov= "Anormal"; 
   }		
					
 pc.addCols(abdo,1,1);
 pc.addCols(orino,1,1);
 pc.addCols(xpulso,1,1);
 pc.addCols(cardiov,1,1);
 
if ( al.size() == 0 ){
    pc.addCols("No hemos encontrado datos!",1,dHeader.size());
}

pc.addTable();
if(isUnifiedExp){
	pc.close();
	response.sendRedirect(redirectFile);}
//}GET
%>
	