
#include <m/m_incl.h>
#include <l/l_incl.h>
#include <stdlib.h>
#include <unistd.h> /* for usleep() */


#ifdef KJB_HAVE_OPENGL
/*
 * Sometimes glu.h includes glut.h--sometimes not.
 */
#ifdef MAC_OSX
#    include <OpenGL/glu.h>
#    include <GLUT/glut.h>
#else 
	#ifdef WIN32
	#	 include <GL/glu.h>
	#	 include <glut.h>
	#else 
	#    include <GL/glu.h>       
	#    include <GL/glut.h>       
	#endif
#endif
#endif

int width, height;
GLenum mouse_modifiers = 0;

void mouse_btn(int button, int state, int x, int y);
void mouse_active_motion(int x, int y);
void mouse_passive_motion(int x, int y);
void mouse_all_motion(int x, int y);
void draw();
void idle();
void reshape(int width, int height);
void key_cb(unsigned char _key, int x, int y);
void cleanup();

int main (int argc, char *argv[])
{
    kjb_init();

    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);
    glutInitWindowPosition(100,100);
    glutInitWindowSize(320,320);
    glutCreateWindow("Default Title");
    glutDisplayFunc(draw);
    glutIdleFunc(idle);
    glutReshapeFunc(reshape);
    glutKeyboardFunc(key_cb);


    glutMouseFunc(mouse_btn);
    glutMotionFunc(mouse_active_motion);
    glutPassiveMotionFunc(mouse_passive_motion);
/*  glutEntryFunc(mouse_entry); */


    glutMainLoop();

    return EXIT_SUCCESS;
}

void mouse_btn(int button, int state, int x, int y)
{
    mouse_modifiers = glutGetModifiers();
    /* GLUT_ACTIVE_SHIFT, etc; */

}

void mouse_active_motion(int x, int y)
{
}

void mouse_passive_motion(int x, int y)
{
}



void draw()
{
    glClearColor(1.0, 1.0, 1.0, 0.0);

	/* clear the drawing buffer */
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);        
    glutSwapBuffers(); 
}

void reshape(int w, int h)
{
    if(w == 0) w = 1;
    if(h == 0) h = 1;

    width = w;
    height = h;

    /* default projection and camera for 2D applications: */
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    glViewport(0, 0, width, height);
    glOrtho(-0.1,1.1, -0.1, 1.1, -1.0, 1.0);
    glMatrixMode(GL_MODELVIEW);

    glLoadIdentity();
    gluLookAt(0.0,0.0,1.0, 
              0.0,0.0,0.0,
              0.0,1.0,0.0);
}

void idle()
{
    usleep(10000);
}

void key_cb(unsigned char _key, int x, int y) 
{
    switch(_key)
    {
        case 'q':
            cleanup();
            exit(0);
            break;
    }
}

void cleanup()
{
    // free memory before quitting
}
