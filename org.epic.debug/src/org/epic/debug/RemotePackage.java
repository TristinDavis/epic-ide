/*
 * Created on 24.12.2004
 *
 * To change the template for this generated file go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
package org.epic.debug;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceVisitor;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.ui.IEditorDescriptor;

/**
 * @author ST
 * 
 * To change the template for this generated type comment go to
 * Window&gt;Preferences&gt;Java&gt;Code Generation&gt;Code and Comments
 */
public class RemotePackage {

	private static ZipOutputStream mOut;
	private static byte[] mBuf = new byte[1024];

	static public void create(RemoteTarget fTarget) {

		String outFilename = "c:/outfile.zip";
		try {
			mOut = new ZipOutputStream(new FileOutputStream(outFilename));
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		String projectName = fTarget.getProjectName();
		if (projectName == null || projectName.length() == 0) {
			return;
		}

		IWorkspaceRoot workspaceRoot = PerlDebugPlugin.getWorkspace().getRoot();
		IProject project = workspaceRoot.getProject(projectName);
		IResourceVisitor visitor = new PerlProjectVisitor();

		try {
			project.accept(visitor);
		} catch (CoreException e) {
			e.printStackTrace();
		}
		try {
			FileInputStream in = new FileInputStream(PerlDebugPlugin
					.getPlugInDir()
					+ "/" + "dumpvar_epic.pm");

			// Add ZIP entry to output stream.
			mOut.putNextEntry(new ZipEntry(fTarget.getStartUpFileDirPath()
					+ "/" + "dumpvar_epic.pm"));

			// Transfer bytes from the file to the ZIP file
			int len;
			while ((len = in.read(mBuf)) > 0) {
				mOut.write(mBuf, 0, len);
			}
			in.close();

			mOut.putNextEntry(new ZipEntry("start_epicDB.pl"));
			String startDB = "$ENV{PERLDB_OPTS}=\"RemotePort="
					+ fTarget.getIP() + ":" + fTarget.getPort()
					+ " DumpReused ReadLine=0\";\n" + "chdir(\""
					+ fTarget.getRemoteDest() + "\");"
					+ "\nsystem(\"perl -d ./" + fTarget.getStartupFileRelPath()
					+ "\");";
			mOut.write(startDB.getBytes());
			mOut.close();
		} catch (IOException e2) {
			// TODO Auto-generated catch block
			e2.printStackTrace();
		}
	}

	static class PerlProjectVisitor implements IResourceVisitor {
		private static final String PERL_EDITOR_ID = "org.epic.perleditor.editors.PerlEditor";
		private static final String EMB_PERL_FILE_EXTENSION = "epl";

		private List fileList = new ArrayList();
		/*
		 * (non-Javadoc)
		 * 
		 * @see org.eclipse.core.resources.IResourceVisitor#visit(org.eclipse.core.resources.IResource)
		 */
		public boolean visit(IResource resource) throws CoreException {
			IEditorDescriptor defaultEditorDescriptor = PerlDebugPlugin
					.getDefault().getWorkbench().getEditorRegistry()
					.getDefaultEditor(resource.getFullPath().toString());

			if (defaultEditorDescriptor == null) {
				return true;
			}

			if (defaultEditorDescriptor.getId().equals(PERL_EDITOR_ID)
					&& !resource.getFileExtension().equals(
							EMB_PERL_FILE_EXTENSION)) {
				String pathname = resource.getFullPath().removeFirstSegments(1)
						.toString();

				FileInputStream in;
				try {
					in = new FileInputStream(resource.getLocation().toString());

					// Add ZIP entry to output stream.
					mOut.putNextEntry(new ZipEntry(pathname));

					// Transfer bytes from the file to the ZIP file
					int len;
					while ((len = in.read(mBuf)) > 0) {
						mOut.write(mBuf, 0, len);
					}
					in.close();
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}

			return true;
		}

	}

}

