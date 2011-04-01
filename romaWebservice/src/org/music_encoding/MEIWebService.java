package org.music_encoding;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringReader;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.TransformerFactoryImpl;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

/**
 * Servlet implementation class MEIWebService
 */
public class MEIWebService extends HttpServlet {
	private static final long serialVersionUID = 1L;
    
	private static final String TEI_DIR = "/var/opt/tei/odds2";
	private static final String TEMP_DIR = "/var/tmp";
	
	
    /**
     * @see HttpServlet#HttpServlet()
     */
    public MEIWebService() {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		String redirect = request.getRequestURL().toString().replaceAll("process$", "");
		response.sendRedirect(redirect);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		boolean isMultipart = ServletFileUpload.isMultipartContent(request);
		
		if(isMultipart) {
			
			PrintWriter out = response.getWriter();
		    out.print(process(request, response));
		    out.close();
			
		}else {
			String redirect = request.getRequestURL().toString().replaceAll("process$", "");
			response.sendRedirect(redirect);
		}
	}

	private String process(HttpServletRequest request, HttpServletResponse response) {
		
		File source = null;
		File customization = null;
		
		try {
			source = new File(TEMP_DIR + "/" + System.currentTimeMillis() + "source.xml");
			customization = new File(TEMP_DIR + "/" + System.currentTimeMillis() + "customization.xml");
			
			try {
				String customizationName = parseUploadedFiles(request, source, customization);
				String relax = transform(customization, source.getAbsolutePath());
				
				response.setContentType("application/x-unknown; charset=utf-8");
				response.setHeader("Content-Disposition", "attachment; filename=" + customizationName.replaceAll(".xml$", ".rng"));
				response.setHeader("Pragma", "no-cache");
				
				return relax;
				
			} catch (Exception e) {
				response.setContentType("text/plain");
				return e.getLocalizedMessage();
			}
		    
		}finally {
			if(source != null && source.exists()) source.delete();
			if(customization != null && customization.exists()) customization.delete();
		}
	}

	private String parseUploadedFiles(HttpServletRequest request, File source, File customization) throws Exception {
		
		String customizationName = "mei";
		
		DiskFileItemFactory factory = new DiskFileItemFactory();
		factory.setSizeThreshold(0);
		ServletFileUpload upload = new ServletFileUpload(factory);
		
		//Request all uploaded files
		List<?> items = null;
		try {
			items = upload.parseRequest(request);
		} catch (FileUploadException e) {
			e.printStackTrace();
		}
		
		if(items != null) {
			Iterator<?> iter = items.iterator();
			while (iter.hasNext()) {
			    FileItem item = (FileItem) iter.next();

			    if (!item.isFormField()) {
			        if(item.getFieldName().equals("source")) {
			        	item.write(source);
			        	
			        }else if(item.getFieldName().equals("customization")) {
			        	item.write(customization);
			        	customizationName = item.getName();
			        }
			    }
			}
		}
		
		return customizationName;
	}
	
	private String transform(File xmlFile, String pathToSource) throws TransformerException, IOException {
		
		StreamSource xml = new StreamSource(xmlFile);
		StreamSource xsl = new StreamSource(new File(TEI_DIR + "/odd2odd.xsl"));
		StreamSource xsl2 = new StreamSource(new File(TEI_DIR + "/odd2relax.xsl"));

		TransformerFactoryImpl tFactory = (TransformerFactoryImpl) TransformerFactoryImpl.newInstance();
		
		Transformer transformer = tFactory.newTransformer(xsl);
		
		transformer.setParameter("selectedSchema", "mei");
		transformer.setParameter("currentDirectory", TEI_DIR);
		transformer.setParameter("TEIC", "true");
		transformer.setParameter("defaultSource", pathToSource);
		
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		transformer.transform(xml, new StreamResult(bos));
		
		String tmpResult = new String(bos.toByteArray(), "utf-8");
		
		transformer = tFactory.newTransformer(xsl2);
		
		transformer.setParameter("selectedSchema", "mei");
		transformer.setParameter("TEIC", "true");

		bos = new ByteArrayOutputStream();
	    
		transformer.transform(new StreamSource(new StringReader(tmpResult)), new StreamResult(bos));
	    bos.close();
	    
	    return new String(bos.toByteArray(), "utf-8");
	}
}
