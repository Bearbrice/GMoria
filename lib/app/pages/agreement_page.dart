import 'package:flutter/material.dart';

class CreateAgreement extends StatelessWidget {
  final String pdfText = """MEMBERSHIP RULES
You
can
format
any
way
you
like.
SECTION TWO
More
items
that
will
scroll
if
the
length
of
this
text
exceeds
the
height
of
the
current
view.
SECTION 3
Seems
like
a
lot
of
effort
to
demonstrate
the
scrollable
view
especially
since
I
don't
know
which
device
this
is.
""";

  Widget build(BuildContext context) {
    return SafeArea(
        child: new Scaffold(
            appBar: new AppBar(title: const Text('Agreement'), actions: [
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop('User Agreed');
                  },
                  child: new Text('AGREE'))
            ]),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(pdfText),
              ),
            )));
  }
}
